From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next 5/7] r8169: add a new chip for RTL8111G
Date: Tue, 2 Apr 2013 00:22:35 +0200
Message-ID: <20130401222235.GB19335@electric-eye.fr.zoreil.com>
References: <1364824539-4156-1-git-send-email-hayeswang@realtek.com>
 <1364824539-4156-5-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1364824539-4156-5-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hayes Wang <hayeswang@realtek.com> :
[...]
> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
> index 0211836..8d41508 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
[...]
> +static void rtl8168g_2_hw_phy_config(struct rtl8169_private *tp)
> +{
> +	rtl_apply_firmware(tp);
> +
> +	rtl_writephy(tp, 0x1f, 0x0bcc);
> +	rtl_w1w0_phy(tp, 0x14, 0x0000, 0x0100);
> +	rtl_writephy(tp, 0x1f, 0x0a44);
> +	rtl_w1w0_phy(tp, 0x11, 0x00c0, 0x0000);
> +	rtl_writephy(tp, 0x1f, 0x0a43);
> +	rtl_writephy(tp, 0x13, 0x8084);
> +	rtl_w1w0_phy(tp, 0x14, 0x0000, 0x6000);
> +	rtl_w1w0_phy(tp, 0x10, 0x1003, 0x0000);
> +
> +	/* Enable UC LPF tune function */
> +	rtl_writephy(tp, 0x1f, 0x0a43);
> +	rtl_writephy(tp, 0x13, 0x8012);
> +	rtl_w1w0_phy(tp, 0x14, 0x8000, 0x0000);
> +
> +	rtl_writephy(tp, 0x1f, 0x0bce);
> +	rtl_writephy(tp, 0x12, 0x8860);
> +
> +	/* Channel Estimation: master */
> +	rtl_writephy(tp, 0x1f, 0x0a43);
> +	rtl_writephy(tp, 0x13, 0x80f3);
> +	rtl_w1w0_phy(tp, 0x14, 0x8b00, 0x7400);
> +	rtl_writephy(tp, 0x13, 0x80f0);
> +	rtl_w1w0_phy(tp, 0x14, 0x3a00, 0xc500);
> +	rtl_writephy(tp, 0x13, 0x80ef);
> +	rtl_w1w0_phy(tp, 0x14, 0x0500, 0xfa00);
> +	rtl_writephy(tp, 0x13, 0x80f6);
> +	rtl_w1w0_phy(tp, 0x14, 0x6e00, 0x9100);
> +	rtl_writephy(tp, 0x13, 0x80ec);
> +	rtl_w1w0_phy(tp, 0x14, 0x6800, 0x9700);
> +	rtl_writephy(tp, 0x13, 0x80ed);
> +	rtl_w1w0_phy(tp, 0x14, 0x7c00, 0x8300);
> +	rtl_writephy(tp, 0x13, 0x80f2);
> +	rtl_w1w0_phy(tp, 0x14, 0xf400, 0x0b00);
> +	rtl_writephy(tp, 0x13, 0x80f4);
> +	rtl_w1w0_phy(tp, 0x14, 0x8500, 0x7a00);
> +
> +	/* Channel Estimation: slave */
> +	rtl_writephy(tp, 0x1f, 0x0a43);
> +	rtl_writephy(tp, 0x13, 0x8110);
> +	rtl_w1w0_phy(tp, 0x14, 0xa800, 0x5700);
> +	rtl_writephy(tp, 0x13, 0x810f);
> +	rtl_w1w0_phy(tp, 0x14, 0x1d00, 0xe200);
> +	rtl_writephy(tp, 0x13, 0x8111);
> +	rtl_w1w0_phy(tp, 0x14, 0xf500, 0x0a00);
> +	rtl_writephy(tp, 0x13, 0x8113);
> +	rtl_w1w0_phy(tp, 0x14, 0x6100, 0x9e00);
> +	rtl_writephy(tp, 0x13, 0x8115);
> +	rtl_w1w0_phy(tp, 0x14, 0x9200, 0x6d00);
> +	rtl_writephy(tp, 0x13, 0x810e);
> +	rtl_w1w0_phy(tp, 0x14, 0x0400, 0xfb00);
> +	rtl_writephy(tp, 0x13, 0x810c);
> +	rtl_w1w0_phy(tp, 0x14, 0x7c00, 0x8300);
> +	rtl_writephy(tp, 0x13, 0x810b);
> +	rtl_w1w0_phy(tp, 0x14, 0x5a00, 0xa500);
> +
> +	/* Channel Estimation: 100 */
> +	rtl_writephy(tp, 0x1f, 0x0a43);
> +	rtl_writephy(tp, 0x13, 0x80d1);
> +	rtl_w1w0_phy(tp, 0x14, 0xff00, 0x0000);
> +	rtl_writephy(tp, 0x13, 0x80cd);
> +	rtl_w1w0_phy(tp, 0x14, 0x9e00, 0x6100);
> +	rtl_writephy(tp, 0x13, 0x80d3);
> +	rtl_w1w0_phy(tp, 0x14, 0x0e00, 0xf100);
> +	rtl_writephy(tp, 0x13, 0x80d5);
> +	rtl_w1w0_phy(tp, 0x14, 0xca00, 0x3500);
> +	rtl_writephy(tp, 0x13, 0x80d7);
> +	rtl_w1w0_phy(tp, 0x14, 0x8400, 0x7b00);
> +
> +	rtl_writephy(tp, 0x1f, 0x0000);

There is close to zero added value for this stuff in the kernel.
You may as well move it completely into the firmware.

-- 
Ueimor
