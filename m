From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: nonagle flags for TSQ
Date: Fri, 07 Feb 2014 07:34:57 -0800
Message-ID: <1391787297.10160.50.camel@edumazet-glaptop2.roam.corp.google.com>
References: <87fvnv2c5k.fsf@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: John Ogness <john.ogness@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:48680 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751463AbaBGPe7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Feb 2014 10:34:59 -0500
Received: by mail-pb0-f52.google.com with SMTP id jt11so3389634pbb.39
        for <netdev@vger.kernel.org>; Fri, 07 Feb 2014 07:34:58 -0800 (PST)
In-Reply-To: <87fvnv2c5k.fsf@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-02-07 at 16:08 +0100, John Ogness wrote:
> Hi,
> 
> This email is referring to your Linux patch
> 46d3ceabd8d98ed0ad10f20c595ca784e34786c5.
> 
> https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=46d3ceabd8d98ed0ad10f20c595ca784e34786c5
> 
> I have a question about the use of tcp_write_xmit() in
> net/ipv4/tcp_output.c
> 
> When tcp_write_xmit() is called, the nonagle flag of the tcp socket is
> ignored and instead 0 is passed. This causes the Nagle-algorithm to be
> used even if it should not be, which in some cases causes a large delay.
> 
> Was there a reason that 0 was hard-coded?
> 
> Although current mainline code has been refactored, 0 is still
> hard-coded for TSQ cases.

Hi John

Do you have any data, like exact kernel version you use, tcpdump or
things like that ?

When the TCP writes are throttled, its only up to the point next packet
is TX completed, and only if you have at least 128KB worth of bytes
consumed in the QDISC/NIC layers for this socket.

We had some issues at very high speeds, not related to Nagle at all.

98e09386c0ef tcp: tsq: restore minimal amount of queueing
c9eeec26e32e tcp: TSQ can use a dynamic limit
d6a4a1041176 tcp: GSO should be TSQ friendly
d01cb20711e3 tcp: add LAST_ACK as a valid state for TSQ

I am not aware of TSQ being a problem for Nagle.

Also take a look at recent TCP autocork patches, as they are more
related to Nagle

a181ceb501b3 tcp: autocork should not hold first packet in write queue
f54b311142a9 tcp: auto corking

Thanks
