From: Steven Brudenell <steven.brudenell@gmail.com>
Subject: Re: tbf/htb qdisc limitations
Date: Tue, 12 Oct 2010 15:31:48 -0400
Message-ID: <AANLkTikQkCcPXtRQGp=MQrjrWtae84VzbENn5x+1yC47@mail.gmail.com>
References: <AANLkTik6_C5pzx=yS=C0VQR2xfg0S57AZAn9WYiGvxe5@mail.gmail.com>
	<4CB1A22B.9090701@gmail.com>
	<AANLkTin_jPp+WEkyJkD_KZyrJ4WX_6dM5wtFNw_ixuzv@mail.gmail.com>
	<20101012101022.GA8578@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:37835 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757373Ab0JLTbt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Oct 2010 15:31:49 -0400
Received: by qyk5 with SMTP id 5so827897qyk.19
        for <netdev@vger.kernel.org>; Tue, 12 Oct 2010 12:31:48 -0700 (PDT)
In-Reply-To: <20101012101022.GA8578@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Yes, it's not allowed according to Documentation/HOWTO. Btw, as you
> can see e.g. in sch_hfsc comments, 64-bit division is avoided too.

i see sch_hfsc avoids do_div in critical areas for performance
reasons, but uses it other places. it should still be alright to
do_div in tbf_change and htb_change_class, right? it would be nice to
compute the rtabs in those functions instead of having userspace do
it.

> I can only say there is no versioning, but backward compatibility
> is crucial, so you need to do some tricks or data duplication.
> You could probably try to get opinions about it with an RFC on
> moving tbf and htb schedulers to 64 bits if you're interested
> (decoupling it from your specific burst problem).

my burst problem is the only semi-legitimate motivation i can think
of. the only other possible motivations i can imagine are setting
"limit" to buffer more than 4GB of packets and setting "rate" to
something more than 32 gigabit; both of these seem kind of dubious. is
there something else you had in mind?

looking more at the netlink tc interface: why is it that the interface
for so many qdiscs consists of passing a big options struct as a
single netlink attr, instead of a bunch of individual attrs? this kind
of seems contrary to the extensibility / flexibility spirit of
netlink, and seems to be getting in the way of changing the interface.
maybe i should RFC about this instead ;)
