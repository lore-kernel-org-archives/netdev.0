From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net] r8169: fix the incorrect tx descriptor version
Date: Tue, 11 Mar 2014 23:28:02 +0100
Message-ID: <20140311222802.GA17770@electric-eye.fr.zoreil.com>
References: <1394521919-4257-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1394521919-4257-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hayes Wang <hayeswang@realtek.com> :
> The tx descriptor version of RTL8111B belong to RTL_TD_0.
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>

Acked-by: Francois Romieu <romieu@fr.zoreil.com>

All 8168b chipsets should had shared the same Tx descriptor layout.

2b7b431858c284b62c18baaf2cea571be2797d5a ("r8169: TSO fixes.") got it
right but it was broken after a couple of weeks by
d58d46b5d85139d18eb939aa7279c160bab70484 ("r8169: jumbo fixes") in 2011:
[...]
 	[RTL_GIGA_MAC_VER_17] =
-		_R("RTL8168b/8111b",	RTL_TD_0, NULL),
+		_R("RTL8168b/8111b",	RTL_TD_1, NULL, JUMBO_4K, false),
 	[RTL_GIGA_MAC_VER_18] =

Oops.

-- 
Ueimor
