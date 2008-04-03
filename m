From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Telnet closing delay
Date: Thu, 3 Apr 2008 14:42:07 +0400
Message-ID: <20080403104207.GA21848@2ka.mipt.ru>
References: <3C59DB883F7B0B4D8096010D45ACCD1323004D@exch.facton.local> <20070502091952.GA6060@2ka.mipt.ru> <3C59DB883F7B0B4D8096010D45ACCD134F21C0@exch.facton.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Beschorner Daniel <Daniel.Beschorner@facton.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:35404 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753752AbYDCKmU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Apr 2008 06:42:20 -0400
Content-Disposition: inline
In-Reply-To: <3C59DB883F7B0B4D8096010D45ACCD134F21C0@exch.facton.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

On Thu, Apr 03, 2008 at 11:32:14AM +0200, Beschorner Daniel (Daniel.Beschorner@facton.com) wrote:
> >> 0.000095 select(4, [0 3], [], [0], NULL) = 1 (in [3])
> >> 0.001779 read(3, 0x8059de0, 8192)  = -1 EIO (Input/output error)
> 
> > Hmm, does not it supposed to stop doing such things on the closed
> > socket and not enter 10000 select/read loop?
> > Server behaves incorrectly in this scenario, why and how it can be
> fixed
> > is another questions better asked the author.
> 
> It must have been indeed triggered by a kernel change or bug, with
> current 2.6.24.4 all works fine again.

I really do not remember what was one year ago, but having a long loop
checking closed socket status is wrong. In recent kernels returned error
could be changed to something like -EINVAL, which is correctly handled
by application, it is impossible to say without caling mind readers, but
they are on vacations right now...

It can be some obscure kernel bug which was fixed or hidden, but with
above description it is hardly possible to tell what is going on.

-- 
	Evgeniy Polyakov
