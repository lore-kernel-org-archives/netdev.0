From: Denis Kirjanov <kda@linux-powerpc.org>
Subject: Re: [PATCH] igb: fix error return code in igb_sysfs_init()
Date: Wed, 27 Mar 2013 18:55:27 +0400
Message-ID: <CAOJe8K3H8+4SAyKEVd8-vjuTNUKcyApZJ1FSYeLCntYXTp6Ddg@mail.gmail.com>
References: <CAPgLHd91Yf2-q1Vh+aTSZ2phqFQC6wbh-ixO6Yh6qu9qsCqnHw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, gregory.v.rose@intel.com,
	peter.p.waskiewicz.jr@intel.com, alexander.h.duyck@intel.com,
	john.ronciak@intel.com, tushar.n.dave@intel.com,
	stephen@networkplumber.org, akeem.g.abodunrin@intel.com,
	yongjun_wei@trendmicro.com.cn, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: Wei Yongjun <weiyj.lk@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f46.google.com ([209.85.219.46]:42491 "EHLO
	mail-oa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753417Ab3C0Oz2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Mar 2013 10:55:28 -0400
Received: by mail-oa0-f46.google.com with SMTP id k1so8849761oag.5
        for <netdev@vger.kernel.org>; Wed, 27 Mar 2013 07:55:27 -0700 (PDT)
In-Reply-To: <CAPgLHd91Yf2-q1Vh+aTSZ2phqFQC6wbh-ixO6Yh6qu9qsCqnHw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wouldn't it be better to return EIO since i2c_new_device()  can fail
for many reasons...


On 3/27/13, Wei Yongjun <weiyj.lk@gmail.com> wrote:
> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
>
> Fix to return a negative error code from the error handling
> case instead of 0, as returned elsewhere in this function.
>
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> ---
>  drivers/net/ethernet/intel/igb/igb_hwmon.c | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/drivers/net/ethernet/intel/igb/igb_hwmon.c
> b/drivers/net/ethernet/intel/igb/igb_hwmon.c
> index 0478a1a..3b750b2 100644
> --- a/drivers/net/ethernet/intel/igb/igb_hwmon.c
> +++ b/drivers/net/ethernet/intel/igb/igb_hwmon.c
> @@ -208,6 +208,7 @@ int igb_sysfs_init(struct igb_adapter *adapter)
>  	if (client == NULL) {
>  		dev_info(&adapter->pdev->dev,
>  			"Failed to create new i2c device..\n");
> +		rc = -ENOMEM;
>  		goto exit;
>  	}
>  	adapter->i2c_client = client;
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
