From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: 3.4-rc: NETDEV WATCHDOG: eth0 (r8169): transmit queue 0 timed out
Date: Tue, 12 Jun 2012 07:26:31 +0200
Message-ID: <20120612052631.GA14567@electric-eye.fr.zoreil.com>
References: <20120501172748.GA17117@electric-eye.fr.zoreil.com> <20120501200423.6804dcf0@stein> <20120501200403.GA20763@electric-eye.fr.zoreil.com> <20120503204813.65468df7@stein> <20120602111335.0b94fb59@stein> <loom.20120611T175322-643@post.gmane.org> <20120611204925.GA7070@electric-eye.fr.zoreil.com> <CAMGsXDRjqsgL=KCR=dQGTNhBS7G-AK-VtDEVT+8bUUqFUR5HsA@mail.gmail.com> <20120611215203.GA8860@electric-eye.fr.zoreil.com> <CAMGsXDT5xu_+gHber-XS=wv9RW7kyUzHNUJN87CuJuNevDuxSw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Tomas Papan <tomas.papan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:54103 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751492Ab2FLFf5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2012 01:35:57 -0400
Content-Disposition: inline
In-Reply-To: <CAMGsXDT5xu_+gHber-XS=wv9RW7kyUzHNUJN87CuJuNevDuxSw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tomas Papan <tomas.papan@gmail.com> :
[...]
> [    2.780758] r8169 0000:03:00.0: eth1: RTL8168e/8111e at
> 0xffffc9000001c000, 80:ee:73:10:ad:44, XID 0c200000 IRQ 46

Let's see if it behaves like RTL_GIGA_MAC_VER_34.

Can you try the patch below ?

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index bbacb37..da46588 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -3766,6 +3766,7 @@ static void rtl_init_rxcfg(struct rtl8169_private *tp)
 	case RTL_GIGA_MAC_VER_22:
 	case RTL_GIGA_MAC_VER_23:
 	case RTL_GIGA_MAC_VER_24:
+	case RTL_GIGA_MAC_VER_33:
 		RTL_W32(RxConfig, RX128_INT_EN | RX_MULTI_EN | RX_DMA_BURST);
 		break;
 	default:
