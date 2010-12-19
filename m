From: =?UTF-8?B?UGF3ZcWCIFN0YXN6ZXdza2k=?= <pstaszewski@itcare.pl>
Subject: Re: Kernel panic eth2 mirred redirect to ifb0
Date: Sun, 19 Dec 2010 21:34:53 +0100
Message-ID: <4D0E6C6D.10806@itcare.pl>
References: <4D0DEDF9.7020102@itcare.pl> <1292773433.18869.153.camel@edumazet-laptop> <4D0E2E52.3090802@itcare.pl> <AANLkTimMY3D_HssWb=Sw=b3tsxEKACk2QUzFzi-HaC-J@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Network Development list <netdev@vger.kernel.org>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.iq.pl ([86.111.241.19]:36600 "EHLO smtp.iq.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932451Ab0LSUe5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Dec 2010 15:34:57 -0500
In-Reply-To: <AANLkTimMY3D_HssWb=Sw=b3tsxEKACk2QUzFzi-HaC-J@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

W dniu 2010-12-19 17:22, Changli Gao pisze:
> 2010/12/20 Pawe=C5=82 Staszewski<pstaszewski@itcare.pl>:
>> W dniu 2010-12-19 16:43, Eric Dumazet pisze:
>>> Unfortunately, we miss the start of panic messages. Could you try t=
o get
>>> them ?
>>>
>> In attached images
>>
> It seems the kernel panic at:
>
>          if (skb_shared(skb))
>                  BUG();
>
> in pskb_expand_head().
>
> It maybe related to my patch:
> http://git.kernel.org/?p=3Dlinux/kernel/git/davem/net-next-2.6.git;a=3D=
commitdiff;h=3D210d6de78c5d7c785fc532556cea340e517955e1
>
> You can try to revert it and test again.
>
> However, the bug is a misuse of pskb_expand_head().
>
patching file net/sched/act_mirred.c
Hunk #1 FAILED at 169.
Hunk #2 succeeded at 195 (offset 10 lines).
1 out of 2 hunks FAILED -- saving rejects to file net/sched/act_mirred.=
c.rej

***************
*** 169,181 ****
                 goto out;
         }

-       at =3D G_TC_AT(skb->tc_verd);
-       skb2 =3D skb_act_clone(skb, GFP_ATOMIC, m->tcf_action);
         if (skb2 =3D=3D NULL)
                 goto out;

         m->tcf_bstats.bytes +=3D qdisc_pkt_len(skb2);
         m->tcf_bstats.packets++;
         if (!(at & AT_EGRESS)) {
                 if (m->tcfm_ok_push)
                         skb_push(skb2, skb2->dev->hard_header_len);
--- 169,181 ----
                 goto out;
         }

+       skb2 =3D skb_act_clone(skb, GFP_ATOMIC);
         if (skb2 =3D=3D NULL)
                 goto out;

         m->tcf_bstats.bytes +=3D qdisc_pkt_len(skb2);
         m->tcf_bstats.packets++;
+       at =3D G_TC_AT(skb->tc_verd);
         if (!(at & AT_EGRESS)) {
                 if (m->tcfm_ok_push)
                         skb_push(skb2, skb2->dev->hard_header_len);

for sch_generic.h was ok.

