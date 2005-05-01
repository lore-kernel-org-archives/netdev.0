From: Alexey Dobriyan <adobriyan@mail.ru>
Subject: Re: [PATCH] resource release cleanup in net/
Date: Sun, 1 May 2005 12:32:42 +0000
Message-ID: <20050501123242.GA8407@mipter.zuzino.mipt.ru>
References: <Pine.LNX.4.62.0504302219520.2094@dragon.hyggekrogen.localhost> <20050501025349.GA9243@mipter.zuzino.mipt.ru> <Pine.LNX.4.62.0505010101580.2094@dragon.hyggekrogen.localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Jouni Malinen <jkmaline@cc.hut.fi>, netdev@oss.sgi.com,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261553AbVEAI3Y@vger.kernel.org>
To: Jesper Juhl <juhl-lkml@dif.dk>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.62.0505010101580.2094@dragon.hyggekrogen.localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, May 01, 2005 at 01:13:28AM +0200, Jesper Juhl wrote:
> On Sun, 1 May 2005, Alexey Dobriyan wrote:
> 
> > On Sat, Apr 30, 2005 at 10:36:00PM +0200, Jesper Juhl wrote:
> > > Since Andrew merged the patch that makes calling crypto_free_tfm() with a 
> > > NULL pointer safe into 2.6.12-rc3-mm1, I made a patch to remove checks for 
> > > NULL before calling that function
> > >  drivers/net/wireless/hostap/hostap_crypt_ccmp.c |    5 -
> > >  drivers/net/wireless/hostap/hostap_crypt_tkip.c |   10 +-
> > >  drivers/net/wireless/hostap/hostap_crypt_wep.c  |    5 -
> > >  net/ieee80211/ieee80211_crypt_ccmp.c            |    5 -
> > >  net/ieee80211/ieee80211_crypt_tkip.c            |   10 +-
> > >  net/ieee80211/ieee80211_crypt_wep.c             |    5 -
> > I think I have a better one for these.
> > 
> > --- linux-2.6.12-rc3-mm1/drivers/net/wireless/hostap/hostap_crypt_ccmp.c	2005-05-01 01:53:50.000000000 +0000
> > +++ linux-2.6.12-rc3-mm1-hostap/drivers/net/wireless/hostap/hostap_crypt_ccmp.c	2005-05-01 02:21:10.000000000 +0000

> > @@ -121,8 +118,7 @@ fail:
> >  static void hostap_ccmp_deinit(void *priv)
> >  {
> >  	struct hostap_ccmp_data *_priv = priv;
> > -	if (_priv && _priv->tfm)
> > -		crypto_free_tfm(_priv->tfm);
> > +	crypto_free_tfm(_priv->tfm);
> >  	kfree(priv);
> >  	module_put(THIS_MODULE);
> >  }
> 
> This will Oops if _priv is NULL. That's why my patch did 
> 
> if (_priv)
> 	crypto_free_tfm(_priv->tfm);

After hostap_ccmp_init() returns successfully:
1. priv is valid pointer	line 95
2. priv->tfm is valid pointer	line 102
