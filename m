From: Jouni Malinen <j@w1.fi>
Subject: Re: [PATCH 7/7] mac80211: Switch to new AEAD interface
Date: Tue, 2 Jun 2015 12:15:43 +0300
Message-ID: <20150602091543.GA3140@w1.fi>
References: <20150521103938.GA23035@gondor.apana.org.au>
 <1433167519.3505.11.camel@sipsolutions.net>
 <1433169326.3505.12.camel@sipsolutions.net>
 <2613062.1qx4rgqk9F@tauon>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>,
	Linux Crypto Mailing List <linux-crypto-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
	Steffen Klassert <steffen.klassert-opNxpl+3fjRBDgjK7y7TUQ@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Stephan Mueller <smueller-T9tCv8IpfcWELgA04lAiVw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <2613062.1qx4rgqk9F@tauon>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 01, 2015 at 05:36:58PM +0200, Stephan Mueller wrote:
> Am Montag, 1. Juni 2015, 16:35:26 schrieb Johannes Berg:
> >IOW, I think something like this would make sense:
> 
> That looks definitely cleaner :-)

Indeed.. That AAD length-in-the-buffer design came from the over ten
year old code that was optimized to cover the CCM construction with the
same buffer and that was not cleaned up when this was converted to use
cryptoapi couple of years ago.

> Though, my main concern was just to ensure that the aad length value is not 
> zero.

It won't be in IEEE 802.11 use cases. The exact length depends on the
IEEE 802.11 frame type, but AAD is constructed in a way that it is
normally a bit over 20 octets while allowing CCM to fit the related
operations into two AES blocks.
 
-- 
Jouni Malinen                                            PGP id EFC895FA
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
