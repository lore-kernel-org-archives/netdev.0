From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] RPS: support 802.1q and pppoe session
Date: Thu, 25 Mar 2010 13:12:57 +0800
Message-ID: <412e6f7f1003242212t242a30e0k635bdfb861c324e4@mail.gmail.com>
References: <4BAAE6E9.6030103@gmail.com> <1269493402.15280.29.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f176.google.com ([209.85.223.176]:54111 "EHLO
	mail-iw0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752264Ab0CYFNS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Mar 2010 01:13:18 -0400
Received: by iwn6 with SMTP id 6so3348509iwn.4
        for <netdev@vger.kernel.org>; Wed, 24 Mar 2010 22:13:17 -0700 (PDT)
In-Reply-To: <1269493402.15280.29.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 25, 2010 at 1:03 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
>
> While this might sounds a good idea, you really should split this in =
two
> parts.
>
> By the way, why not handling IPIP too ?

I'm not sure if it is a good idea to support VLAN and PPPOE, and
actually David don't like it. :(

>
> Because I believe 802.1q part has no added value for instance, since
> packet handled by CPUX will be decoded and passed to VLAN device, hav=
ing
> a chance to be fully taken by RPS, since we go back to netif_rx().
>
> Probably same thing for IPIP / PPPOE can be discussed.

It is useful when Linux is run as a bridge.

>
> I agree we might need a flag or something to reset rxhash to 0 somewh=
ere
> (probably in non accelerated vlan rx handling) to force second
> get_rps_cpu() invocation to recompute it. This small correction has n=
o
> cost if put outside of get_rps_cpus().
>
> If get_rps_cpus() is too complex, it might become too slow for typica=
l
> use. We should find smart ways to solve your performance problem if t=
hey
> ever exist.
>

It means that more than one IPI will be sent for just a single
packets, I don't think the cost is acceptable.

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
