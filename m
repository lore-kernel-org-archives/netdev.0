From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH] tcp: do not promote SPLICE_F_NONBLOCK to socket O_NONBLOCK
Date: Fri, 18 Jul 2008 16:24:15 +0400
Message-ID: <20080718122414.GA10688@2ka.mipt.ru>
References: <200807171633.49791.opurdila@ixiacom.com> <200807180052.33918.opurdila@ixiacom.com> <20080718105344.GA481@2ka.mipt.ru> <200807181418.59493.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:38754 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755347AbYGRMYT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jul 2008 08:24:19 -0400
Content-Disposition: inline
In-Reply-To: <200807181418.59493.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 18, 2008 at 02:18:59PM +0300, Octavian Purdila (opurdila@ixiacom.com) wrote:
> I know that. But I am arguing that splice API does not required not to block 
> even when the SPLICE_F_NONBLOCK is used. So changing this behavior the way I 
> suggested will still be conformant with the splice API requirements.

It will block in sending and/or other than network reading. With your
patch if receiving socket was opened in blocking mode, than there is no
way to finish splice-in until whole requested number of bytes are read.
SPLICE_F_NONBLOCK is an extension, consider it like recv() with temporal
non-blocking flag.

> Sorry, it was an unfortunate example :) This is not about not enough data 
> being available. Lets change the number of packets in the example with 20 
> instead of 16 (and keep the size to 17) - the splice call will still block 
> because of the pipe being full. The pipe can only hold PIPE_BUFFERS packets 
> (which is 16 currently).

Why? It will read its data from 16 packets, then send them into another end
of the pipe :)

You propose to change a very useful splice feature (actually you would just
remove it at all with the same results for reading network path, since
it is essentially what you did :) - not to block when it is possible.

This kind of non-blocking mode was added for performance issues too:
consider application which reads from the network and writes into the
file, while there is no data in the socket it can write what was already
read into any object attached to the given end of the pipe.

-- 
	Evgeniy Polyakov
