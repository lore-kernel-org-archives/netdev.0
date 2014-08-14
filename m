From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net-next] r8169:add support for RTL8168H and RTL8107E
Date: Thu, 14 Aug 2014 14:23:07 -0700 (PDT)
Message-ID: <20140814.142307.1009368551221010220.davem@redhat.com>
References: <1407942373-17094-1-git-send-email-hau@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org
To: hau@realtek.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38610 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754900AbaHNVXN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Aug 2014 17:23:13 -0400
In-Reply-To: <1407942373-17094-1-git-send-email-hau@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chun-Hao Lin <hau@realtek.com>
Date: Wed, 13 Aug 2014 23:06:13 +0800

> RTL8168H is Realtek PCIe Gigabit Ethernet controller.
> RTL8107E is Realtek PCIe Fast Ethernet controller.
> 
> This patch add support for these two chips.
> 
> Signed-off-by: Chun-Hao Lin <hau@realtek.com>

Please don't break the indentation like you have here:

> +			rtl_w1w0_eri(tp,
> +						0x0dc,
> +						ERIAR_MASK_0100,
> +						MagicPacket_v2,
> +						0x0000,
> +						ERIAR_EXGMAC);
 ...
> +			rtl_w1w0_eri(tp,
> +						0x0dc,
> +						ERIAR_MASK_0100,
> +						0x0000,
> +						MagicPacket_v2,
> +						ERIAR_EXGMAC);
 ...
> @@ -4495,15 +4791,19 @@ static void rtl8169_hw_reset(struct rtl8169_private *tp)
>  	    tp->mac_version == RTL_GIGA_MAC_VER_31) {
>  		rtl_udelay_loop_wait_low(tp, &rtl_npq_cond, 20, 42*42);
>  	} else if (tp->mac_version == RTL_GIGA_MAC_VER_34 ||
> -	           tp->mac_version == RTL_GIGA_MAC_VER_35 ||
> -	           tp->mac_version == RTL_GIGA_MAC_VER_36 ||
> -	           tp->mac_version == RTL_GIGA_MAC_VER_37 ||
> -	           tp->mac_version == RTL_GIGA_MAC_VER_40 ||
> -	           tp->mac_version == RTL_GIGA_MAC_VER_41 ||
> -	           tp->mac_version == RTL_GIGA_MAC_VER_42 ||
> -	           tp->mac_version == RTL_GIGA_MAC_VER_43 ||
> -	           tp->mac_version == RTL_GIGA_MAC_VER_44 ||
> -	           tp->mac_version == RTL_GIGA_MAC_VER_38) {
> +				tp->mac_version == RTL_GIGA_MAC_VER_35 ||
> +				tp->mac_version == RTL_GIGA_MAC_VER_36 ||
> +				tp->mac_version == RTL_GIGA_MAC_VER_37 ||
> +				tp->mac_version == RTL_GIGA_MAC_VER_38 ||
> +				tp->mac_version == RTL_GIGA_MAC_VER_40 ||
> +				tp->mac_version == RTL_GIGA_MAC_VER_41 ||
> +				tp->mac_version == RTL_GIGA_MAC_VER_42 ||
> +				tp->mac_version == RTL_GIGA_MAC_VER_43 ||
> +				tp->mac_version == RTL_GIGA_MAC_VER_44 ||
> +				tp->mac_version == RTL_GIGA_MAC_VER_45 ||
> +				tp->mac_version == RTL_GIGA_MAC_VER_46 ||
> +				tp->mac_version == RTL_GIGA_MAC_VER_47 ||
> +				tp->mac_version == RTL_GIGA_MAC_VER_48) {
>  		RTL_W8(ChipCmd, RTL_R8(ChipCmd) | StopReq);
>  		rtl_udelay_loop_wait_high(tp, &rtl_txcfg_empty_cond, 100, 666);
>  	} else {

None of these changes are indented correctly, and in the last hunk the original
code was perfectly indented and you should have not adjusted it.

On a multi-line conditional or function call, the second and subsequent lines
should start exactly at the first column after the openning parenthesis of
the initial line.

You must use the appropriate number of TAB then SPACE characters necessary
to achieve this.

If you are indenting these lines only using TAB characters, you are doing it
incorrectly.

Please audit your entire patch for this problem, thanks.
