From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: tbf/htb qdisc limitations
Date: Tue, 12 Oct 2010 23:59:32 +0200
Message-ID: <20101012215932.GA1945@del.dom.local>
References: <AANLkTik6_C5pzx=yS=C0VQR2xfg0S57AZAn9WYiGvxe5@mail.gmail.com>
 <4CB1A22B.9090701@gmail.com>
 <AANLkTin_jPp+WEkyJkD_KZyrJ4WX_6dM5wtFNw_ixuzv@mail.gmail.com>
 <20101012101022.GA8578@ff.dom.local>
 <AANLkTikQkCcPXtRQGp=MQrjrWtae84VzbENn5x+1yC47@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Steven Brudenell <steven.brudenell@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:38116 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751611Ab0JLV7i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Oct 2010 17:59:38 -0400
Received: by wwb24 with SMTP id 24so11011wwb.1
        for <netdev@vger.kernel.org>; Tue, 12 Oct 2010 14:59:37 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <AANLkTikQkCcPXtRQGp=MQrjrWtae84VzbENn5x+1yC47@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 12, 2010 at 03:31:48PM -0400, Steven Brudenell wrote:
> > Yes, it's not allowed according to Documentation/HOWTO. Btw, as you
> > can see e.g. in sch_hfsc comments, 64-bit division is avoided too.
> 
> i see sch_hfsc avoids do_div in critical areas for performance
> reasons, but uses it other places. it should still be alright to
> do_div in tbf_change and htb_change_class, right? it would be nice to
> compute the rtabs in those functions instead of having userspace do
> it.

Right, tbf_change or htb_change_class are on the "slow path". But
to compute these rtabs you need passing more parameters than rate.
And userspace would still do most of it for backward compatibility.

> 
> > I can only say there is no versioning, but backward compatibility
> > is crucial, so you need to do some tricks or data duplication.
> > You could probably try to get opinions about it with an RFC on
> > moving tbf and htb schedulers to 64 bits if you're interested
> > (decoupling it from your specific burst problem).
> 
> my burst problem is the only semi-legitimate motivation i can think
> of. the only other possible motivations i can imagine are setting
> "limit" to buffer more than 4GB of packets and setting "rate" to
> something more than 32 gigabit; both of these seem kind of dubious. is
> there something else you had in mind?

No, mainly 10 gigabit rates and additionally 64-bit stats.

> looking more at the netlink tc interface: why is it that the interface
> for so many qdiscs consists of passing a big options struct as a
> single netlink attr, instead of a bunch of individual attrs? this kind
> of seems contrary to the extensibility / flexibility spirit of
> netlink, and seems to be getting in the way of changing the interface.
> maybe i should RFC about this instead ;)

Sure, you can (I'm not the netlink expert).

Jarek P.
