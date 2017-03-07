From: Siva Reddy Kallam <siva.kallam@broadcom.com>
Subject: Re: [PATCH net-next] tg3: Add the ability to conditionally build w/ HWMON
Date: Tue, 7 Mar 2017 21:32:10 +0530
Message-ID: <CAMet4B6Oe0nmW7fFkz=skDkLHfE9yp_u6bjhorKUB7eFB-0D0A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
        Prashant Sreedharan <prashant@broadcom.com>,
        Michael Chan <mchan@broadcom.com>,
        "David S. Miller" <davem@davemloft.net>,
        Alexander Duyck <aduyck@mirantis.com>,
        Thomas Gleixner <tglx@linutronix.de>,
        Nicolas Pitre <nicolas.pitre@linaro.org>,
        Jon Mason <jon.mason@broadcom.com>,
        open list <linux-kernel@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 7, 2017 at 2:26 AM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> Introduce a Kconfig option: CONFIG_TIGON3_HWMON which allows to build
> in/out support for thermal sensors reported by Tigon3 NICs.
>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
Acked-by: Siva Reddy Kallam <siva.kallam@broadcom.com>
> ---
>  drivers/net/ethernet/broadcom/Kconfig | 8 +++++++-
>  drivers/net/ethernet/broadcom/tg3.c   | 7 +++++++
>  2 files changed, 14 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/broadcom/Kconfig b/drivers/net/ethernet/broadcom/Kconfig
> index 940fb24bba21..96413808c726 100644
> --- a/drivers/net/ethernet/broadcom/Kconfig
> +++ b/drivers/net/ethernet/broadcom/Kconfig
> @@ -109,7 +109,6 @@ config TIGON3
>         tristate "Broadcom Tigon3 support"
>         depends on PCI
>         select PHYLIB
> -       select HWMON
>         imply PTP_1588_CLOCK
>         ---help---
>           This driver supports Broadcom Tigon3 based gigabit Ethernet cards.
> @@ -117,6 +116,13 @@ config TIGON3
>           To compile this driver as a module, choose M here: the module
>           will be called tg3.  This is recommended.
>
> +config TIGON3_HWMON
> +       bool "Broadcom Tigon3 HWMON support"
> +       default y
> +       depends on TIGON3 && HWMON && !(TIGON3=y && HWMON=m)
> +       ---help---
> +         Say Y if you want to expose the thermal sensor on Tigon3 devices.
> +
>  config BNX2X
>         tristate "Broadcom NetXtremeII 10Gb support"
>         depends on PCI
> diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
> index 30d1eb9ebec9..f395b951f5e7 100644
> --- a/drivers/net/ethernet/broadcom/tg3.c
> +++ b/drivers/net/ethernet/broadcom/tg3.c
> @@ -825,6 +825,7 @@ static int tg3_ape_event_lock(struct tg3 *tp, u32 timeout_us)
>         return timeout_us ? 0 : -EBUSY;
>  }
>
> +#ifdef CONFIG_TIGON3_HWMON
>  static int tg3_ape_wait_for_event(struct tg3 *tp, u32 timeout_us)
>  {
>         u32 i, apedata;
> @@ -904,6 +905,7 @@ static int tg3_ape_scratchpad_read(struct tg3 *tp, u32 *data, u32 base_off,
>
>         return 0;
>  }
> +#endif
>
>  static int tg3_ape_send_event(struct tg3 *tp, u32 event)
>  {
> @@ -10744,6 +10746,7 @@ static int tg3_init_hw(struct tg3 *tp, bool reset_phy)
>         return tg3_reset_hw(tp, reset_phy);
>  }
>
> +#ifdef CONFIG_TIGON3_HWMON
>  static void tg3_sd_scan_scratchpad(struct tg3 *tp, struct tg3_ocir *ocir)
>  {
>         int i;
> @@ -10826,6 +10829,10 @@ static void tg3_hwmon_open(struct tg3 *tp)
>                 dev_err(&pdev->dev, "Cannot register hwmon device, aborting\n");
>         }
>  }
> +#else
> +static inline void tg3_hwmon_close(struct tg3 *tp) { }
> +static inline void tg3_hwmon_open(struct tg3 *tp) { }
> +#endif /* CONFIG_TIGON3_HWMON */
>
>
>  #define TG3_STAT_ADD32(PSTAT, REG) \
> --
> 2.9.3
>
