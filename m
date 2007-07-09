From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH 2.6] SoftMAC : fix ESSID problem
Date: Tue, 10 Jul 2007 00:46:23 +0200
Message-ID: <200707100046.23832.mb@bu3sch.de>
References: <20070709221922.GB1381@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: jt@hpl.hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:57503
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756239AbXGIWr4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2007 18:47:56 -0400
In-Reply-To: <20070709221922.GB1381@bougret.hpl.hp.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 10 July 2007 00:19:22 Jean Tourrilhes wrote:
> 	Hi,
> 
> 	Victor Porton reported that the SoftMAC layer had random
> problem when setting the ESSID :
> 		http://bugzilla.kernel.org/show_bug.cgi?id=8686
> 	After investigation, it turned out to be worse, the SoftMAC
> layer is left in an inconsistent state. The fix is pretty trivial.
>         John : would you mind pushing that to 2.6.23 ?
>         Thanks...
> 
>         Jean
> 
> Signed-off-by: Jean Tourrilhes <jt@hpl.hp.com>
> 
> -----------------------------------------------------------
> 
> --- linux/net/ieee80211/softmac/ieee80211softmac_assoc.j1.c	2007-07-09 13:56:13.000000000 -0700
> +++ linux/net/ieee80211/softmac/ieee80211softmac_assoc.c	2007-07-09 13:56:41.000000000 -0700
> @@ -271,8 +271,11 @@ ieee80211softmac_assoc_work(struct work_
>  			 */
>  			dprintk(KERN_INFO PFX "Associate: Scanning for networks first.\n");
>  			ieee80211softmac_notify(mac->dev, IEEE80211SOFTMAC_EVENT_SCAN_FINISHED, ieee80211softmac_assoc_notify_scan, NULL);
> -			if (ieee80211softmac_start_scan(mac))
> +			if (ieee80211softmac_start_scan(mac)) {
>  				dprintk(KERN_INFO PFX "Associate: failed to initiate scan. Is device up?\n");
> +				mac->associnfo.associating = 0;
> +				mac->associnfo.associated = 0;
> +			}
>  			goto out;
>  		} else {
>  			mac->associnfo.associating = 0;
> 

Acked-by: Michael Buesch <mb@bu3sch.de>


-- 
Greetings Michael.
