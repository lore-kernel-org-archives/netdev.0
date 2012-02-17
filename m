From: Neal Cardwell <ncardwell@google.com>
Subject: Re: Re: Re: Re: limited network bandwidth with 3.2.x kernels
Date: Fri, 17 Feb 2012 11:41:04 -0500
Message-ID: <CADVnQynNEzJQvWdFeSDadPA7uZsraC64m=kNwe8M8sDsCyBD1Q@mail.gmail.com>
References: <1329399616.9395.9.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<16215291.4ftfQWZto1@localhost.localdomain>
	<1329429573.5450.2.camel@edumazet-laptop>
	<1843012.xoR1aAbfqy@localhost.localdomain>
	<1329431746.2438.8.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: alekcejk@googlemail.com, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f53.google.com ([209.85.216.53]:42603 "EHLO
	mail-qw0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751509Ab2BQQlF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2012 11:41:05 -0500
Received: by qafk1 with SMTP id k1so3746237qaf.19
        for <netdev@vger.kernel.org>; Fri, 17 Feb 2012 08:41:04 -0800 (PST)
In-Reply-To: <1329431746.2438.8.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 16, 2012 at 5:35 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> An incoming skb is considered as "good citizen" in term of memory usa=
ge
> if its truesize is no more than
> len + len/4 =A0 (if adv_win_scale =3D=3D 2)
>
> That was true when truesize was 1500+NET_SKB_PAD+sizeof(sk_buff),
> but not true anymore when truesize is 2048+sizeof(sk_buff), or even m=
ore
> when its 4096+sizeof(sk_buff)
>
> So receiver doesnt increase rcv_ssthresh and cannot open its window.
>
> tcp_grow_window() should be tweaked to :
>
> 1) Relax the requirements
> 2) Allow bigger increase in case of super packets (LRO/GRO)

That sounds great. Is this something you're planning on tackling?

neal
