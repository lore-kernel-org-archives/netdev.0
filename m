From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v2 net-next 1/2] r8169: support RTL8106E
Date: Tue, 3 Jul 2012 13:01:01 +0200
Message-ID: <20120703110101.GA4779@electric-eye.fr.zoreil.com>
References: <1340966060-2749-1-git-send-email-hayeswang@realtek.com> <1341221002-1522-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1341221002-1522-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hayes Wang <hayeswang@realtek.com> :
> Support the new chip RTL8106E.
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>

Almost-Acked-by: Francois Romieu <romieu@fr.zoreil.com>

Simple bidirectional traffic worked fine (rsync + wget + ping) both
with and without tx checksumming offload.

Wol g or u worked as well. Link was ok and traffic flowing after a
suspend to ram.

No problem with module removal / insertion / device up / traffic loop.

> +#define FIRMWARE_8106E_1	"rtl_nic/rtl8106e-1.fw"

I did not notice it. Was it submitted ?

It was obviously not required for testing :o)

> @@ -1933,6 +1941,8 @@ static void rtl8169_get_mac_version(struct rtl8169_private *tp,
>  		{ 0x7c800000, 0x30000000,	RTL_GIGA_MAC_VER_11 },
>  
>  		/* 8101 family. */
> +		{ 0x7cf00000, 0x44900000,	RTL_GIGA_MAC_VER_39 },
> +		{ 0x7c800000, 0x44800000,	RTL_GIGA_MAC_VER_39 },
>  		{ 0x7c800000, 0x44000000,	RTL_GIGA_MAC_VER_37 },
>  		{ 0x7cf00000, 0x40b00000,	RTL_GIGA_MAC_VER_30 },
>  		{ 0x7cf00000, 0x40a00000,	RTL_GIGA_MAC_VER_30 },

Realtek's 1.022.00 8101 driver only maps { 0x7c800000; 0x44800000 } to
a generic device - if at all - and it maps { 0x7cf00000; 0x44800000 }
to a different chipset (namely CFG_METHOD_15 where RTL_GIGA_MAC_VER_39
is CFG_METHOD_16).

Why should both drivers diverge ?

-- 
Ueimor
