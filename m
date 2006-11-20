From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH 6/13] d80211: change the identifier netdev to
 ieee80211_hw
Date: Mon, 20 Nov 2006 18:57:52 +0100
Message-ID: <20061120185752.684b1b09@griffin.suse.cz>
References: <1163802439.3392.47.camel@johannes.berg>
	<1163963898.15473.36.camel@johannes.berg>
	<1163964522.15473.52.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Simon Barber <simon@devicescape.com>,
	Jouni Malinen <jkm@devicescape.com>,
	Hong Liu <hong.liu@intel.com>,
	David Kimdon <david.kimdon@devicescape.com>,
	Michael Wu <flamingice@sourmilk.net>,
	Michael Buesch <mbuesch@freenet.de>,
	Ivo van Doorn <ivdoorn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:10389 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S966284AbWKTR5z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Nov 2006 12:57:55 -0500
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1163964522.15473.52.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 19 Nov 2006 20:28:42 +0100, Johannes Berg wrote:
> Note that the patch changes the meaning of ieee80211_hw, previously it
> was allocated by the driver and given to the stack as a hardware
> description, now it is allocated by ieee80211alloc_hw() and then the
> driver fills it before calling ieee80211_register_hw().

If you are at it, why not to rename ieee80211_hw to some better name?
We need to rename ieee80211_local and I think ieee80211_hw would be
very good name for it. What about renaming of ieee80211_hw to
ieee80211_dev?

> A later patch fixes the FIXME introduced here where hw fragmentation is
> checked by having a function assigned or not---if functions are supposed to
> be assigned now for all hw we need a new flag for that if some driver has
> boards that can and other boards that cannot support it.

Setting set_frag_threshold when the card doesn't do fragmentation makes
no sense. Not setting set_frag_threshold when the card needs to do
fragmentation in hardware makes no sense as well. Therefore
assigning/not assigning of set_frag_threshold gives the same
information as the flag.

> -/* Configuration block used by the low-level driver to tell the 802.11 code
> - * about supported hardware features and to pass function pointers to callback
> - * functions. */
> +/* this is driver-visible part of the per-hw state the stack keeps.
> + * if you change something in here, call */

Call what?

> -	/* ieee80211 drivers must assign this instead of the callback in
> +	/* This replaces the callback that would usually be in
>  	 * &struct net_device. dev->flags, dev->mc_count and dev->mc_list must

You probably want to delete the last "must".

> -	 * not be used; use passed parameters and ieee80211_get_mc_list_item()
> -	 * instead. */
> -	void (*set_multicast_list)(struct net_device *dev,
> +	 * are replaced by the parameters and ieee80211_get_mc_list_item(). */
> +	void (*set_multicast_list)(struct ieee80211_hw *hw,
>  				   unsigned short flags, int mc_count);

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
