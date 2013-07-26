From: Dominique Martinet <dominique.martinet@cea.fr>
Subject: Re: [V9fs-developer] [PATCH] net: trans_rdma: remove unused
 function
Date: Fri, 26 Jul 2013 09:01:38 +0200
Message-ID: <20130726070138.GA28421@nautica>
References: <1374497956-32104-1-git-send-email-andi@etezian.org>
 <20130724.154646.2283898956674234778.davem@davemloft.net>
 <1374707387.29835.23.camel@x61.thuisdomein>
 <20130724.164514.393667021861625699.davem@davemloft.net>
 <20130725061411.GA8579@nautica>
 <20130725064802.GA12569@nautica>
 <CAFkjPTm1FH24EfWMDrXTh7DmU8WAb0ji-jkUgkayqMzfWj9O0A@mail.gmail.com>
 <20130725190506.GA32375@nautica>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Latchesar Ionkov <lucho@ionkov.net>, pebolle@tiscali.nl,
	netdev@vger.kernel.org,
	linux-kernel <linux-kernel@vger.kernel.org>, andi@etezian.org,
	rminnich@sandia.gov,
	V9FS Developers <v9fs-developer@lists.sourceforge.net>,
	David Miller <davem@davemloft.net>
To: Eric Van Hensbergen <ericvh@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nautica.notk.org ([91.121.71.147]:58130 "EHLO nautica.notk.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752680Ab3GZHBz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Jul 2013 03:01:55 -0400
Content-Disposition: inline
In-Reply-To: <20130725190506.GA32375@nautica>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I think I need to stop sending mails before triple-checking things!
So sorry for the multiple mails again.

Dominique Martinet wrote on Thu, Jul 25, 2013 :
> [rdma_cancelled]
> There is one problem though - if the server handles the original request
> before getting the flush, the receive buffer will be consumed and we
> won't send a new one, so we'll starve the reception queue.
> I'm afraid I don't have any bright idea there...

This still looks correct to me.


> While we are on reception buffer issues, there is another problem with
> the queue of receive buffers, even without flush, in the following
> scenario:
>  - post a buffer for tag 0, on a hanging request
>  - post a buffer for tag 1
>  - reply for tag 1 will come on buffer from tag 0
>  - post another request with tag 1.. the buffer already is in the queue,
> and we don't know we can post the buffer associated with tag 0 back.

It actually looks like the reply buffers are swapped properly - taken
out of the req struct into the context on send, then given back to the
appropriate req on reception, so on normal operation there's no problem
with what I described - sorry for crying wolf.
 
> I haven't found how to reproduce this perfectly yet, but a dd with
> blocksize 1MB and one with blocksize 10B in parallel brought the
> mountpoint down (and the whole server was completely unavailable for the
> duration of the dd - TCP sessions timed out, I even got IO errors on the
> local disk :D)

I need to run more tests to explain what happens with the two dds, but
it's easily reproductible with debugs on, I guess that helps with a race
somewhere.

Regards,
-- 
Dominique Martinet
