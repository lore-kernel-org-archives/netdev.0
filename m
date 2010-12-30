From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [net-next-2.6 PATCH v2 4/4] dcbnl: cleanup
Date: Thu, 30 Dec 2010 11:17:41 -0800
Message-ID: <4D1CDAD5.4010602@intel.com>
References: <1293726430.29378.95.camel@lb-tlvb-shmulik.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	Eilon Greenstein <eilong@broadcom.com>,
	"Liu, Lucy" <lucy.liu@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Shmulik Ravid <shmulikr@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:19930 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754966Ab0L3TRm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Dec 2010 14:17:42 -0500
In-Reply-To: <1293726430.29378.95.camel@lb-tlvb-shmulik.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/30/2010 8:27 AM, Shmulik Ravid wrote:
> A couple of small cleanups for patches:
> [net-next-2.6 PATCH 1/3] dcbnl: add support for ieee8021Qaz attributes
> [net-next-2.6 PATCH 2/3] dcbnl: add appliction tlv handlers
> [net-next-2.6 PATCH 3/3] net_dcb: add application notifiers
> 
> Signed-off-by: Shmulik Ravid <shmulikr@broadcom.com>
> ---

Good catch, thanks a lot. I will roll this into my patch and push a v2 so that we don't introduce a known bug. Of course I'll give you credit.

Thanks,
John.

>  net/dcb/dcbnl.c |    6 ++++--
>  1 files changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
> index b387816..ff3c12d 100644
> --- a/net/dcb/dcbnl.c
> +++ b/net/dcb/dcbnl.c
> @@ -1626,8 +1626,10 @@ u8 dcb_setapp(struct net_device *dev, struct dcb_app *new)
>  	if (new->priority) {
>  		struct dcb_app_type *entry;
>  		entry = kmalloc(sizeof(struct dcb_app_type), GFP_ATOMIC);
> -		if (!entry)
> +		if (!entry) {
> +			spin_unlock(&dcb_lock);
>  			return -ENOMEM;
> +		}
>  
>  		memcpy(&entry->app, new, sizeof(*new));
>  		strncpy(entry->name, dev->name, IFNAMSIZ);
> @@ -1640,7 +1642,7 @@ out:
>  }
>  EXPORT_SYMBOL(dcb_setapp);
>  
> -void dcb_flushapp(void)
> +static void dcb_flushapp(void)
>  {
>  	struct dcb_app_type *app;
>  

