From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [RFC] r8169 : why SG / TX checksum are default disabled
Date: Wed, 18 Jul 2012 01:40:37 +0200
Message-ID: <20120717234037.GA26972@electric-eye.fr.zoreil.com>
References: <1342564781.2626.1264.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Hayes Wang <hayeswang@realtek.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:50077 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753420Ab2GQXxR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 19:53:17 -0400
Content-Disposition: inline
In-Reply-To: <1342564781.2626.1264.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> :
[...]
> I was wondering why Scatter Gather (NETIF_F_SG) and TX checksum
> (NETIF_F_IP_CSUM) were disabled by default on r8169.

It was not unconditionally stable. For a number of reasons:
- incompatibility with jumbo frames.
  rtl_chip_infos now allows to take care of it
- lack of support for chipset dependent Tx descriptor 
  rtl_tx_desc_info handles it. There are yet a few unused ipv6 bits. No idea
  how useable they are.
- some false alarms due to different issues and probably some others
  I could hunt for in the archives.

> Couldnt we enable them by default, maybe for a whitelist of "good"
> nics ?

Sure.

Hayes, should we not add into the kernel driver something similar to
the rtl8168_start_xmit::skb_checksum_help stuff in Realtek's 8168 driver ?
There seems to be a bug for (skb->len < 60 && RTL_GIGA_MAC_VER_34.

> (I found that activating them with ethtool automatically enables GSO,
>  and performance with GSO is not good)

It's still an improvement though, isn't it ?

-- 
Ueimor
