From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH 2.6.18] WE-21 for ipw2200
Date: Tue, 12 Sep 2006 14:02:59 -0400
Message-ID: <20060912180253.GC7703@tuxdriver.com>
References: <20060830010140.GF8405@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	"James P. Ketrenos" <ipw2100-admin@linux.intel.com>,
	Zhu Yi <yi.zhu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:5649 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1030337AbWILSJ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Sep 2006 14:09:59 -0400
To: Jean Tourrilhes <jt@hpl.hp.com>
Content-Disposition: inline
In-Reply-To: <20060830010140.GF8405@bougret.hpl.hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 29, 2006 at 06:01:40PM -0700, Jean Tourrilhes wrote:
>         Hi,
> 
>         WE-21 for IPW2200 driver...
> 
>         Jean
> 
> Signed-off-by: Jean Tourrilhes <jt@hpl.hp.com>
> 
> -----------------------------------------------------------
> 
> diff -u -p linux/drivers/net/wireless/ipw2200.20.c linux/drivers/net/wireless/ipw2200.c
> --- linux/drivers/net/wireless/ipw2200.20.c	2006-08-28 17:35:29.000000000 -0700
> +++ linux/drivers/net/wireless/ipw2200.c	2006-08-28 17:36:09.000000000 -0700
> @@ -8861,7 +8861,7 @@ static int ipw_wx_set_essid(struct net_d
>  	int length = 0;
>  	mutex_lock(&priv->mutex);
>  	if (wrqu->essid.flags && wrqu->essid.length) {
> -		length = wrqu->essid.length - 1;
> +		length = wrqu->essid.length;
>  		essid = extra;
>  	}
>  	if (length == 0) {

This hunk doesn't apply to the upstream branch of wireless-2.6.
I propose this one instead:

@@ -8875,8 +8875,6 @@ static int ipw_wx_set_essid(struct net_d
         }
 
 	length = min((int)wrqu->essid.length, IW_ESSID_MAX_SIZE);
-	if (!extra[length - 1])
-		length--;
 
 	priv->config |= CFG_STATIC_ESSID;
 
Everything else stays the same...OK?

John
-- 
John W. Linville
linville@tuxdriver.com
