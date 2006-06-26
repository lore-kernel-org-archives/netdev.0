From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH] bcm43xx: enable shared key authentication
Date: Mon, 26 Jun 2006 21:10:46 +0200
Message-ID: <200606262110.46747.mb@bu3sch.de>
References: <20060616195022.E73CD8A3591@zog.reactivated.net> <20060626183821.GB30706@tuxdriver.com> <200606262106.40278.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Daniel Drake <dsd@gentoo.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:4286
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S932927AbWFZTL3
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Jun 2006 15:11:29 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <200606262106.40278.mb@bu3sch.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 26 June 2006 21:06, Michael Buesch wrote:
> On Monday 26 June 2006 20:38, John W. Linville wrote:
> > On Fri, Jun 16, 2006 at 08:50:22PM +0100, Daniel Drake wrote:
> > > I recently patched softmac to enable shared key authentication. This small patch
> > > will enable crazy or unfortunate bcm43xx users to use this new capability.
> > > 
> > > Signed-off-by: Daniel Drake <dsd@gentoo.org>
> > > 
> > > Index: linux/drivers/net/wireless/bcm43xx/bcm43xx_main.c
> > > ===================================================================
> > > --- linux.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c
> > > +++ linux/drivers/net/wireless/bcm43xx/bcm43xx_main.c
> > > @@ -3599,6 +3599,10 @@ static void bcm43xx_ieee80211_set_securi
> > >  		secinfo->encrypt = sec->encrypt;
> > >  		dprintk(KERN_INFO PFX "   .encrypt = %d\n", sec->encrypt);
> > >  	}
> > > +	if (sec->flags & SEC_AUTH_MODE) {
> > > +		secinfo->auth_mode = sec->auth_mode;
> > > +		dprintk(KERN_INFO PFX "   .auth_mode = %d\n", sec->auth_mode);
> > > +	}
> > >  	if (bcm->initialized && !bcm->ieee->host_encrypt) {
> > >  		if (secinfo->enabled) {
> > >  			/* upload WEP keys to hardware */
> > 
> > I had problems applying this one.  I recall having a similar problem w/
> > a patch in the last round of merging as well.
> > 
> > The version of bcm43xx_main.c in wireless-2.6 looks like this
> > (post patch):
> > 
> > 
> > 		secinfo->encrypt = sec->encrypt;
> > 		dprintk(", .encrypt = %d", sec->encrypt);
> > 	}
> > 	if (sec->flags & SEC_AUTH_MODE) {
> > 		secinfo->auth_mode = sec->auth_mode;
> > 		dprintk(", .auth_mode = %d\n", sec->auth_mode);
> > 	}
> > 	dprintk("\n");
> > 	if (bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED &&
> > 	    !bcm->ieee->host_encrypt) {
> > 
> > Am I missing a patch?
> > 
> > Please make sure I get any patches that are missing from wireless-2.6
> > -- it is obviously better if we are all on the same page! :-)
> 
> Daniel's patch is diffed to an older tree.
> wireless-2.6 recently removed bcm->initialized and friends
> and added a more usable and more correct bcm43xx_status() flag.
> 
> So, basically the following just has to be added after
> the other if(sec->flags & FOO), but before the if(bcm43xx_status...)
> 
> if (sec->flags & SEC_AUTH_MODE) {
> 	secinfo->auth_mode = sec->auth_mode;
> 	dprintk(KERN_INFO PFX "   .auth_mode = %d\n", sec->auth_mode);
> }

Oh, the printk is wrong. The \n has to be removed.

-- 
Greetings Michael.
