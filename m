From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH] ieee80211: Fix sparse warning
Date: Fri, 2 Feb 2007 15:32:01 -0500
Message-ID: <20070202203201.GB9382@tuxdriver.com>
References: <45c1394b.An8WeE68tSLsbJYy%Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Buesch <mb@bu3sch.de>, netdev@vger.kernel.org,
	Bcm43xx-dev@lists.berlios.de
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:4661 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1946075AbXBBVGC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Feb 2007 16:06:02 -0500
Content-Disposition: inline
In-Reply-To: <45c1394b.An8WeE68tSLsbJYy%Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 31, 2007 at 06:50:19PM -0600, Larry Finger wrote:
> Sparse issues the warning "warning: symbol 'crypt' shadows an earlier one"
> in net/ieee80211/ieee80211_tx.c.
> 
> Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
> ---
> 
> Index: wireless-2.6/net/ieee80211/ieee80211_tx.c
> ===================================================================
> --- wireless-2.6.orig/net/ieee80211/ieee80211_tx.c
> +++ wireless-2.6/net/ieee80211/ieee80211_tx.c
> @@ -502,8 +502,6 @@ int ieee80211_xmit(struct sk_buff *skb, 
>  		if (host_encrypt)
>  			ieee80211_encrypt_fragment(ieee, skb_frag, hdr_len);
>  		else if (host_build_iv) {
> -			struct ieee80211_crypt_data *crypt;
> -
>  			crypt = ieee->crypt[ieee->tx_keyidx];
>  			atomic_inc(&crypt->refcnt);
>  			if (crypt->ops->build_iv)

Couldn't you remove the "crypt = ieee->crypt[ieee->tx_keyidx];"
as well?

John
-- 
John W. Linville
linville@tuxdriver.com
