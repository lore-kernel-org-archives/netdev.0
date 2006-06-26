From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH] bcm43xx: enable shared key authentication
Date: Mon, 26 Jun 2006 14:38:29 -0400
Message-ID: <20060626183821.GB30706@tuxdriver.com>
References: <20060616195022.E73CD8A3591@zog.reactivated.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, mb@bu3sch.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:3845 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S932638AbWFZSiw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jun 2006 14:38:52 -0400
To: Daniel Drake <dsd@gentoo.org>
Content-Disposition: inline
In-Reply-To: <20060616195022.E73CD8A3591@zog.reactivated.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 16, 2006 at 08:50:22PM +0100, Daniel Drake wrote:
> I recently patched softmac to enable shared key authentication. This small patch
> will enable crazy or unfortunate bcm43xx users to use this new capability.
> 
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

I had problems applying this one.  I recall having a similar problem w/
a patch in the last round of merging as well.

The version of bcm43xx_main.c in wireless-2.6 looks like this
(post patch):


		secinfo->encrypt = sec->encrypt;
		dprintk(", .encrypt = %d", sec->encrypt);
	}
	if (sec->flags & SEC_AUTH_MODE) {
		secinfo->auth_mode = sec->auth_mode;
		dprintk(", .auth_mode = %d\n", sec->auth_mode);
	}
	dprintk("\n");
	if (bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED &&
	    !bcm->ieee->host_encrypt) {

Am I missing a patch?

Please make sure I get any patches that are missing from wireless-2.6
-- it is obviously better if we are all on the same page! :-)

Thanks,

John
-- 
John W. Linville
linville@tuxdriver.com
