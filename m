From: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH V6 net-next 5/5] net:hns: Add the init code to disable
 Hip06 "Hardware VLAN assist"
Date: Wed, 2 Dec 2015 22:46:56 +0300
Message-ID: <565F4AB0.5020100@cogentembedded.com>
References: <1449075171-4820-1-git-send-email-salil.mehta@huawei.com>
 <1449075171-4820-6-git-send-email-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Salil Mehta <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, pawel.moll-5wv7dgnIgG8@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
	paul.gortmaker-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org, ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org,
	galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, catalin.marinas-5wv7dgnIgG8@public.gmane.org, will.deacon-5wv7dgnIgG8@public.gmane.org,
	arnd-r2nGTMty4D4@public.gmane.org, liguozhu-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org, yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	dingtianhong-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, zhangfei.gao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org,
	huangdaode-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org, kenneth-lee-2012-H32Fclmsjq1BDgjK7y7TUQ@public.gmane.org,
	mehta.salil.lnk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, xuwei5-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org,
	lisheng011-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1449075171-4820-6-git-send-email-salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello.

On 12/02/2015 07:52 PM, Salil Mehta wrote:

> This patch adds the initializzation code to disable the hardware
> vlan support for VLAN Tag stripping by default for now.
>
> Proper support of "hardware VLAN assitance" feature would
> soon come in the next coming patches.
>
> Signed-off-by: Salil Mehta <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> ---
>
> PATCH V6:
> - No change over the earlier patch
>
> PATCH V5:
> - Minor merge/reject change resolved to application of previous patch
>
> PATCH V4/V3/V2:
> - No change over the initial floated patch
>
> PATCH V1:
> - Initial code to disable the hardware VLAN assist for now
> ---
>   drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c |    7 +++++++
>   drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h |    1 +
>   2 files changed, 8 insertions(+)
>
> diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c
> index b5e4c44..f302ef9 100644
> --- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c
> +++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c
> @@ -176,6 +176,11 @@ static void hns_ppe_cnt_clr_ce(struct hns_ppe_cb *ppe_cb)
>   			 PPE_CNT_CLR_CE_B, 1);
>   }
>
> +static void hns_ppe_set_vlan_strip(struct hns_ppe_cb *ppe_cb, int en)
> +{
> +	dsaf_write_dev(ppe_cb, PPEV2_VLAN_STRIP_EN_REG, en);

    Why not call it directly?

> +}
> +
>   /**
>    * hns_ppe_checksum_hw - set ppe checksum caculate
>    * @ppe_device: ppe device
> @@ -336,6 +341,8 @@ static void hns_ppe_init_hw(struct hns_ppe_cb *ppe_cb)
>   	hns_ppe_cnt_clr_ce(ppe_cb);
>
>   	if (!AE_IS_VER1(dsaf_dev->dsaf_ver)) {
> +		hns_ppe_set_vlan_strip(ppe_cb, 0);
> +
>   		/* set default RSS key in h/w */
>   		hns_ppe_set_rss_key(ppe_cb, ppe_cb->rss_key);
>
> diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
> index 98c163e..6c18ca9 100644
> --- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
> +++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
> @@ -318,6 +318,7 @@
>   #define PPE_CFG_PARSE_TAG_REG			0x94
>   #define PPE_CFG_PRO_CHECK_EN_REG		0x98
>   #define PPEV2_CFG_TSO_EN_REG                    0xA0
> +#define PPEV2_VLAN_STRIP_EN_REG                 0xAC

    Please indent with tabs, like all the surrounding #define's are indented 
(except PPEV2_CFG_TSO_EN_REG).

>   #define PPE_INTEN_REG				0x100
>   #define PPE_RINT_REG				0x104
>   #define PPE_INTSTS_REG				0x108

MBR, Sergei

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
