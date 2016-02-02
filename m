From: Julian Calaby <julian.calaby@gmail.com>
Subject: Re: [PATCH] rtlwifi: Fix reusable codes in core.c
Date: Wed, 3 Feb 2016 09:15:04 +1100
Message-ID: <CAGRGNgVHEsA693tQxf0Mv_4wSu-4wG7sphhRRB0gbU6o9nzZ_Q@mail.gmail.com>
References: <20160202154855.GA8990@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Kalle Valo <kvalo@codeaurora.org>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Byeoungwook Kim <quddnr145@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160202154855.GA8990@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Byeoungwook,

On Wed, Feb 3, 2016 at 2:48 AM, Byeoungwook Kim <quddnr145@gmail.com> wrote:
> rtl_*_delay() functions were reused same codes about addr variable.
> So i have converted to rtl_addr_delay() from code about addr variable.
>
> Conditional codes in rtl_addr_delay() were improved in readability and
> performance by using switch codes.
>
> Signed-off-by: Byeoungwook Kim <quddnr145@gmail.com>
> ---
>  drivers/net/wireless/realtek/rtlwifi/core.c | 48 +++++++++++------------------
>  1 file changed, 18 insertions(+), 30 deletions(-)
>
> diff --git a/drivers/net/wireless/realtek/rtlwifi/core.c b/drivers/net/wireless/realtek/rtlwifi/core.c
> index 4ae421e..c1193d1 100644
> --- a/drivers/net/wireless/realtek/rtlwifi/core.c
> +++ b/drivers/net/wireless/realtek/rtlwifi/core.c
> @@ -37,36 +37,34 @@
>
>  void rtl_addr_delay(u32 addr)
>  {
> -       if (addr == 0xfe)
> +       switch (addr) {
> +       case 0xfe:
>                 mdelay(50);
> -       else if (addr == 0xfd)
> +               break;
> +       case 0xfd:
>                 mdelay(5);
> -       else if (addr == 0xfc)
> +               break;
> +       case 0xfc:
>                 mdelay(1);
> -       else if (addr == 0xfb)
> +               break;
> +       case 0xfb:
>                 udelay(50);
> -       else if (addr == 0xfa)
> +               break;
> +       case 0xfa:
>                 udelay(5);
> -       else if (addr == 0xf9)
> +               break;
> +       case 0xf9:
>                 udelay(1);
> +               break;
> +       };

As you're introducing a case statement here, you could consolidate the
addresses that have the same delays, i.e.

case 0xfe:
case 0xfb:
    mdelay(50);
    break;

also, you should arguably be doing this cleanup in a separate patch, i.e.

1. Convert open coded instances to use this function (i.e. the changes
below this comment)
2. Improve the function

>  }
>  EXPORT_SYMBOL(rtl_addr_delay);
>
>  void rtl_rfreg_delay(struct ieee80211_hw *hw, enum radio_path rfpath, u32 addr,
>                      u32 mask, u32 data)
>  {
> -       if (addr == 0xfe) {
> -               mdelay(50);
> -       } else if (addr == 0xfd) {
> -               mdelay(5);
> -       } else if (addr == 0xfc) {
> -               mdelay(1);
> -       } else if (addr == 0xfb) {
> -               udelay(50);
> -       } else if (addr == 0xfa) {
> -               udelay(5);
> -       } else if (addr == 0xf9) {
> -               udelay(1);
> +       if (addr >= 0xf9 && addr <= 0xfe) {
> +               rtl_addr_delay(addr);
>         } else {
>                 rtl_set_rfreg(hw, rfpath, addr, mask, data);
>                 udelay(1);
> @@ -76,18 +74,8 @@ EXPORT_SYMBOL(rtl_rfreg_delay);
>
>  void rtl_bb_delay(struct ieee80211_hw *hw, u32 addr, u32 data)
>  {
> -       if (addr == 0xfe) {
> -               mdelay(50);
> -       } else if (addr == 0xfd) {
> -               mdelay(5);
> -       } else if (addr == 0xfc) {
> -               mdelay(1);
> -       } else if (addr == 0xfb) {
> -               udelay(50);
> -       } else if (addr == 0xfa) {
> -               udelay(5);
> -       } else if (addr == 0xf9) {
> -               udelay(1);
> +       if (addr >= 0xf9 && addr <= 0xfe) {
> +               rtl_addr_delay(addr);
>         } else {
>                 rtl_set_bbreg(hw, addr, MASKDWORD, data);
>                 udelay(1);

Thanks,

-- 
Julian Calaby

Email: julian.calaby@gmail.com
Profile: http://www.google.com/profiles/julian.calaby/
