From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 16/19] net: hns: fix bug that alloc skb fail lead
 to port unavailable
Date: Tue, 21 Jun 2016 16:25:14 +0300
Message-ID: <097b1147-3587-9579-0f94-f42be130773c@cogentembedded.com>
References: <1466481399-70080-1-git-send-email-Yisen.Zhuang@huawei.com>
 <1466481399-70080-17-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: liguozhu@huawei.com, huangdaode@hisilicon.com, arnd@arndb.de,
	andriy.shevchenko@linux.intel.com, andrew@lunn.ch,
	geliangtang@163.com, ivecera@redhat.com, fengguang.wu@intel.com,
	charles.chenxin@huawei.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linuxarm@huawei.com
To: Yisen Zhuang <Yisen.Zhuang@huawei.com>, davem@davemloft.net,
	salil.mehta@huawei.com, yankejian@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f53.google.com ([209.85.215.53]:34581 "EHLO
	mail-lf0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751827AbcFUNZT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2016 09:25:19 -0400
Received: by mail-lf0-f53.google.com with SMTP id h129so23911450lfh.1
        for <netdev@vger.kernel.org>; Tue, 21 Jun 2016 06:25:18 -0700 (PDT)
In-Reply-To: <1466481399-70080-17-git-send-email-Yisen.Zhuang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 6/21/2016 6:56 AM, Yisen Zhuang wrote:

> From: Jun He <hjat2005@huawei.com>
>
> When hns_nic_poll_rx_skb alloc skb fail, it will break receive cycle and
> read new fbd_num to start new receive cycle. It recomputes cycle num is
> fbd_num minus clean_count, actually this cycle num is too big because
> it drop out receive cycle. It brings about the port unavailable.
>
> So we will goto out when alloc skb fail to fix this bug.
>
> Signed-off-by: Jun He <hjat2005@huawei.com>
> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
> Signed-off-by: Yisen Zhuang <Yisen.Zhuang@huawei.com>
> ---
>  drivers/net/ethernet/hisilicon/hns/hns_enet.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/ethernet/hisilicon/hns/hns_enet.c b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
> index f49246d..c0ce37b 100644
> --- a/drivers/net/ethernet/hisilicon/hns/hns_enet.c
> +++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
> @@ -768,10 +768,10 @@ recv:
>  			clean_count = 0;
>  		}
>
> -		/* poll one pkg*/
> +		/* poll one pkt*/

    How about adding a space before */?

[...]

MBR, Sergei
