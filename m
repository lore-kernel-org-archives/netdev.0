From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Revert 462fb2af9788a82a534f8184abfde31574e1cfa0 (bridge :
 Sanitize skb before it enters the IP stack)
Date: Fri, 16 May 2014 08:19:59 -0700
Message-ID: <1400253599.7973.181.camel@edumazet-glaptop2.roam.corp.google.com>
References: <536F8C0F.4090206@davidnewall.com>
	,<5370CB47.4010400@davidnewall.com>
	 <DUB123-W514EA0A4A29F520778F2FFED350@phx.gbl>
	 <53715D67.8020803@davidnewall.com> <53736ACC.9010902@davidnewall.com>
	 <537621AC.1060409@davidnewall.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Lukas Tribus <luky-37@hotmail.com>,
	Netdev <netdev@vger.kernel.org>, "fw@strlen.de" <fw@strlen.de>
To: David Newall <davidn@davidnewall.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:55855 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755757AbaEPPUD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 11:20:03 -0400
Received: by mail-pa0-f45.google.com with SMTP id ey11so2689935pad.18
        for <netdev@vger.kernel.org>; Fri, 16 May 2014 08:20:02 -0700 (PDT)
In-Reply-To: <537621AC.1060409@davidnewall.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2014-05-17 at 00:03 +0930, David Newall wrote:
> We should revert commit 462fb2af9788a82a534f8184abfde31574e1cfa0 (bridge 
> : Sanitize skb before it enters the IP stack) because it corrupts IP 
> packets with RR or TS options set, only partially updating the IP header 
> and leaving an incorrect checksum.
> 
> The argument for introducing the change is at lkml.org/lkml/2010/8/30/391:
> 
> The bridge layer can overwrite the IPCB using the
> BR_INPUT_SKB_CB macro. In br_nf_dev_queue_xmit,
> if we recieve a packet greater in size than the bridge
> device MTU, we call ip_fragment which in turn will lead to
> icmp_send calling ip_options_echo if the DF flag is set.
> ip_options_echo will then incorrectly try to parse the IPCB as
> IP options resulting in a buffer overflow.
> This change refills the CB area back with IP
> options before ip_fragment calls icmp_send. If we fail parsing,
> we zero out the IPCB area to guarantee that the stack does
> not get corrupted.
> 
> A bridge should not fragment packets; an *ethernet* bridge should not 
> need to.  Fragmenting packets is the job of higher level protocol.
> 
> --- br_netfilter.c	2014-01-20 13:10:07.000000000 +1030
> +++ br_netfilter.c.prop	2014-05-16 23:07:57.975386905 +0930


Is this meant to be an official patch ?

Please 

1) CC patch author (Bandan Das <bandan.das@stratus.com>) so he has a way
to comment if he no longer follows netdev ?

2) Read Documentation/SubmittingPatches 

>   	return NF_STOLEN;
> +
> +inhdr_error:
> +//      IP_INC_STATS_BH(IpInHdrErrors);

Don't leave this // 

Thanks
