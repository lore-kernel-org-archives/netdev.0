From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net 4/6] net: hns: adds uc match for debug port
Date: Fri, 4 Mar 2016 16:39:19 +0300
Message-ID: <56D99007.6090804@cogentembedded.com>
References: <1457053798-93513-1-git-send-email-huangdaode@hisilicon.com>
 <1457053798-93513-5-git-send-email-huangdaode@hisilicon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: liguozhu@hisilicon.com, Yisen.Zhuang@huawei.com,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org, linuxarm@huawei.com,
	salil.mehta@huawei.com, kenneth-lee-2012@foxmail.com,
	xuwei5@hisilicon.com, lisheng011@huawei.com, yankejian@huawei.com
To: Daode Huang <huangdaode@hisilicon.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f170.google.com ([209.85.217.170]:34402 "EHLO
	mail-lb0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751251AbcCDNjW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2016 08:39:22 -0500
Received: by mail-lb0-f170.google.com with SMTP id cf7so44973151lbb.1
        for <netdev@vger.kernel.org>; Fri, 04 Mar 2016 05:39:22 -0800 (PST)
In-Reply-To: <1457053798-93513-5-git-send-email-huangdaode@hisilicon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/4/2016 4:09 AM, Daode Huang wrote:

> This patch adds uc match for debug port by:
> 1)Enables uc match of debug port when initializing gmac
> 2)Enables uc match of mac address register2
>
> Signed-off-by: Daode Huang <huangdaode@hisilicon.com>
> Signed-off-by: lipeng <lipeng321@huawei.com>

    True/full name is required here.

> ---
>   drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c | 18 +++++++++++++++++-
>   drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h  |  2 ++
>   2 files changed, 19 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c
> index b8517b0..2591a51 100644
> --- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c
> +++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c
[...]
> @@ -407,8 +419,12 @@ static void hns_gmac_set_mac_addr(void *mac_drv, char *mac_addr)
>
>   		u32 low_val = mac_addr[5] | (mac_addr[4] << 8)
>   			| (mac_addr[3] << 16) | (mac_addr[2] << 24);
> +
> +		u32 val = dsaf_read_dev(drv, GMAC_STATION_ADDR_HIGH_2_REG);
> +		u32 sta_addr_en = dsaf_get_bit(val, GMAC_ADDR_EN_B);

    Empty line needed after declarations.

>   		dsaf_write_dev(drv, GMAC_STATION_ADDR_LOW_2_REG, low_val);
> -		dsaf_write_dev(drv, GMAC_STATION_ADDR_HIGH_2_REG, high_val);
> +		dsaf_write_dev(drv, GMAC_STATION_ADDR_HIGH_2_REG,
> +			       high_val | (sta_addr_en << GMAC_ADDR_EN_B));
>   	}
>   }
>
[...]

MBR, Sergei
