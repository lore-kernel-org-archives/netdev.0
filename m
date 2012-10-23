From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v2 net-next 2/2] r8169: update the settings for RTL8111G
Date: Tue, 23 Oct 2012 21:41:26 +0200
Message-ID: <20121023194126.GC10463@electric-eye.fr.zoreil.com>
References: <1350893153-18320-1-git-send-email-hayeswang@realtek.com> <1350974831-1438-1-git-send-email-hayeswang@realtek.com> <1350974831-1438-2-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1350974831-1438-2-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hayes Wang <hayeswang@realtek.com> :
> Update the parameters of RTL8111G

I am Jack's Broken Heart. :o/

In a not too distant future somebody may try to figure if things should
be fed into one of the numerous -stable trees. He will appreciate figuring
from the comment if this commit is supposed to fix anything or if it's a
pure performance thing or whatever.

The pll_power changes could be a bugfix for instance. The ALDPS change
isn't.

> Signed-off-by: Hayes Wang <hayeswang@realtek.com>
> ---
>  drivers/net/ethernet/realtek/r8169.c | 118 ++++++++++++++++++++++++++++++-----
>  1 file changed, 101 insertions(+), 17 deletions(-)
> 
> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
> index cdd46de..3a393f7 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
[...]
> @@ -3400,29 +3410,57 @@ static void rtl8168g_1_hw_phy_config(struct rtl8169_private *tp)
>  {
>  	static const u16 mac_ocp_patch[] = {
>  		0xe008, 0xe01b, 0xe01d, 0xe01f,
> -		0xe021, 0xe023, 0xe025, 0xe027,
> +		0xe022, 0xe025, 0xe031, 0xe04d,
>  		0x49d2, 0xf10d, 0x766c, 0x49e2,
>  		0xf00a, 0x1ec0, 0x8ee1, 0xc60a,
> -
>  		0x77c0, 0x4870, 0x9fc0, 0x1ea0,
>  		0xc707, 0x8ee1, 0x9d6c, 0xc603,
>  		0xbe00, 0xb416, 0x0076, 0xe86c,
> -		0xc602, 0xbe00, 0x0000, 0xc602,
> -
> -		0xbe00, 0x0000, 0xc602, 0xbe00,
> -		0x0000, 0xc602, 0xbe00, 0x0000,
> -		0xc602, 0xbe00, 0x0000, 0xc602,
> -		0xbe00, 0x0000, 0xc602, 0xbe00,
> -
> -		0x0000, 0x0000, 0x0000, 0x0000
> +		0xc602, 0xbe00, 0xa000, 0xc602,
> +		0xbe00, 0x0000, 0x1b76, 0xc202,
> +		0xba00, 0x059c, 0x1b76, 0xc602,
> +		0xbe00, 0x065a, 0x74e6, 0x1b78,
> +		0x46dc, 0x1300, 0xf005, 0x74f8,
> +		0x48c3, 0x48c4, 0x8cf8, 0x64e7,
> +		0xc302, 0xbb00, 0x06a0, 0x74e4,
> +		0x49c5, 0xf106, 0x49c6, 0xf107,
> +		0x48c8, 0x48c9, 0xe011, 0x48c9,
> +		0x4848, 0xe00e, 0x4848, 0x49c7,
> +		0xf00a, 0x48c9, 0xc60d, 0x1d1f,
> +		0x8dc2, 0x1d00, 0x8dc3, 0x1d11,
> +		0x8dc0, 0xe002, 0x4849, 0x94e5,
> +		0xc602, 0xbe00, 0x01f0, 0xe434,
> +		0x49d9, 0xf01b, 0xc31e, 0x7464,
> +		0x49c4, 0xf114, 0xc31b, 0x6460,
> +		0x14fa, 0xfa02, 0xe00f, 0xc317,
> +		0x7460, 0x49c0, 0xf10b, 0xc311,
> +		0x7462, 0x48c1, 0x9c62, 0x4841,
> +		0x9c62, 0xc30a, 0x1c04, 0x8c60,
> +		0xe004, 0x1c15, 0xc305, 0x8c60,
> +		0xc602, 0xbe00, 0x0384, 0xe434,
> +		0xe030, 0xe61c, 0xe906
>  	};

Do you remember why firmware loading was introduced in the first place ?

I find it increasingly hard to believe that it does not apply here.

[...]
>  	/* Patch code for GPHY reset */
> +	r8168_mac_ocp_write(tp, 0xfc26, 0x0000);
> +	r8168_mac_ocp_write(tp, 0xfc28, 0x0000);
> +	r8168_mac_ocp_write(tp, 0xfc2a, 0x0000);
> +	r8168_mac_ocp_write(tp, 0xfc2c, 0x0000);
> +	r8168_mac_ocp_write(tp, 0xfc2e, 0x0000);
> +	r8168_mac_ocp_write(tp, 0xfc30, 0x0000);
> +	r8168_mac_ocp_write(tp, 0xfc32, 0x0000);
> +	r8168_mac_ocp_write(tp, 0xfc34, 0x0000);
> +	r8168_mac_ocp_write(tp, 0xfc36, 0x0000);
>  	for (i = 0; i < ARRAY_SIZE(mac_ocp_patch); i++)
> -		r8168_mac_ocp_write(tp, 0xf800 + 2*i, mac_ocp_patch[i]);
> +		r8168_mac_ocp_write(tp, 0xf800 + 2 * i, mac_ocp_patch[i]);
>  	r8168_mac_ocp_write(tp, 0xfc26, 0x8000);
>  	r8168_mac_ocp_write(tp, 0xfc28, 0x0075);
> +	r8168_mac_ocp_write(tp, 0xfc2e, 0x059b);
> +	r8168_mac_ocp_write(tp, 0xfc30, 0x0659);
> +	r8168_mac_ocp_write(tp, 0xfc32, 0x069f);
> +	r8168_mac_ocp_write(tp, 0xfc34, 0x01cd);
> +	r8168_mac_ocp_write(tp, 0xfc36, 0x0303);

Within a few weeks / months there will be a new update with a new
set of completely obscure parameters. It will takes a kernel cycle or
more to be distributed.

There should be some higher level data struct that could use a mundane
"for" loop and some indirection in place of this code bloat.

It is getting out of control.

-- 
Ueimor
