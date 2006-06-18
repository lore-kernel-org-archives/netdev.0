From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH] bcm43xx: enable shared key authentication
Date: Sat, 17 Jun 2006 23:01:25 -0400
Message-ID: <1150599685.2519.7.camel@localhost.localdomain>
References: <20060616195022.E73CD8A3591@zog.reactivated.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, netdev@vger.kernel.org, mb@bu3sch.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:42173 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S932068AbWFRDBN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Jun 2006 23:01:13 -0400
To: Daniel Drake <dsd@gentoo.org>
In-Reply-To: <20060616195022.E73CD8A3591@zog.reactivated.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-06-16 at 20:50 +0100, Daniel Drake wrote:
> I recently patched softmac to enable shared key authentication. This small patch
> will enable crazy or unfortunate bcm43xx users to use this new capability.

Meaning that _until now_, softmac couldn't do Shared Key auth???  That
might explain a few NM bugs I think I've seen floating around.

Dan

> Signed-off-by: Daniel Drake <dsd@gentoo.org>
> 
> Index: linux/drivers/net/wireless/bcm43xx/bcm43xx_main.c
> ===================================================================
> --- linux.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c
> +++ linux/drivers/net/wireless/bcm43xx/bcm43xx_main.c
> @@ -3599,6 +3599,10 @@ static void bcm43xx_ieee80211_set_securi
>  		secinfo->encrypt = sec->encrypt;
>  		dprintk(KERN_INFO PFX "   .encrypt = %d\n", sec->encrypt);
>  	}
> +	if (sec->flags & SEC_AUTH_MODE) {
> +		secinfo->auth_mode = sec->auth_mode;
> +		dprintk(KERN_INFO PFX "   .auth_mode = %d\n", sec->auth_mode);
> +	}
>  	if (bcm->initialized && !bcm->ieee->host_encrypt) {
>  		if (secinfo->enabled) {
>  			/* upload WEP keys to hardware */
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

