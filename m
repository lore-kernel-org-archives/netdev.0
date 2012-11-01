From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next] r8169: enable internal ASPM and clock request settings
Date: Thu, 1 Nov 2012 23:21:39 +0100
Message-ID: <20121101222139.GC7708@electric-eye.fr.zoreil.com>
References: <1351780651-1271-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1351780651-1271-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hayes Wang <hayeswang@realtek.com> :
> The following chips need to enable internal settings to let ASPM
> and clock request work.

No objection, you know better than me.

[...]
> @@ -5145,7 +5146,10 @@ static void rtl_hw_start_8168g_1(struct rtl8169_private *tp)
>  
>  	RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
>  	RTL_W32(MISC, RTL_R32(MISC) & ~RXDV_GATED_EN);
> +	RTL_W32(MISC, RTL_R32(MISC) | FORCE_CLK);

I wonder if those could had been merged.

[...]
> @@ -5407,7 +5417,10 @@ static void rtl_hw_start_8106(struct rtl8169_private *tp)
>  	/* Force LAN exit from ASPM if Rx/Tx are not idle */
>  	RTL_W32(FuncEvent, RTL_R32(FuncEvent) | 0x002800);
>  
> -	RTL_W32(MISC, (RTL_R32(MISC) | DISABLE_LAN_EN) & ~EARLY_TALLY_EN);
> +	RTL_W32(MISC, RTL_R32(MISC) & ~EARLY_TALLY_EN);
> +	RTL_W32(MISC, RTL_R32(MISC) | DISABLE_LAN_EN | FORCE_CLK);

As well as those.

-- 
Ueimor
