From: Hirokazu Takahashi <taka@valinux.co.jp>
Subject: Re: [PATCH] sendfile() and UDP socket
Date: Fri, 19 Sep 2008 21:28:54 +0900 (JST)
Message-ID: <20080919.212854.19019802.taka@valinux.co.jp>
References: <1221387956.9204.7.camel@fry>
	<20080916.210117.31865904.taka@valinux.co.jp>
	<200809182031.01291.rdenis@simphalempin.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johaahn@gmail.com, netdev@vger.kernel.org
To: rdenis@simphalempin.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from fms-01.valinux.co.jp ([210.128.90.1]:55042 "EHLO
	mail.valinux.co.jp" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751495AbYISM27 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2008 08:28:59 -0400
In-Reply-To: <200809182031.01291.rdenis@simphalempin.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

> > UDP is a datagram protocol, so I think applications using UDP should
> > care about the size of packets they are going to send rather than
> > expecting that the messages will be split into several packets
> > automatically. If some of the packets have lost, it will be really hard for
> > the applications to re-create the same ones to send again.
> 
> Also, why use UDP for this... If you want stream semantics, why not use TCP or 
> SCTP instead?

I think a lot of VoIP and video streaming services are working on UDP.
Linux NFS over UDP also uses this feature.

> > If you want send a large file over UDP, the typical code will be like:
> 
> > while (...) {
> >         sendmsg(fd, &apl_header, sizeof(apl_header), MSG_MORE);
> >         offset += sendfile(fd, offset, count);
> > }
> 
> Correct me if I am wrong, but... Unless you have a big MTU (as _not_ in 1500 
> bytes :D), doing an extra syscall might be slower than copying data in a 
> single vectorized sendmsg() syscall.

That's not true.
Even if the MTU is small, you can send a UDP message whose size can be
up to 64KB at once. They will be split into several IP packets without
any copies.

And more, copying data will pollute the cache memory much, which cannot
be ignored if you want send tons of data of files.


Thanks,
Hirokazu Takahashi.
