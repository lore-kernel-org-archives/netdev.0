From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: ieee80211_i.h: shouldn't struct ps_data.tim be aligned unsigned
 long?
Date: Wed, 18 Dec 2013 10:19:07 +0100
Message-ID: <1387358347.4694.2.camel@jlt4.sipsolutions.net>
References: <1387354564.13593.26.camel@joe-AO722>
	 (sfid-20131218_091612_149215_EA847147)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@redhat.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:48815 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752115Ab3LRJTR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 04:19:17 -0500
In-Reply-To: <1387354564.13593.26.camel@joe-AO722> (sfid-20131218_091612_149215_EA847147)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-12-18 at 00:16 -0800, Joe Perches wrote:

> Perhaps the
> 	u8 tim[sizeof...]
> member should be marked
> 	__aligned(sizeof(unsigned long))
> so that the cast to ulong when bitmap_empty
> is actually forced to be ulong aligned?

yeah, I suppose that's true.

> diff --git a/net/mac80211/ieee80211_i.h b/net/mac80211/ieee80211_i.h
> index ed5bf8b..e5a9c51 100644
> --- a/net/mac80211/ieee80211_i.h
> +++ b/net/mac80211/ieee80211_i.h
> @@ -245,7 +245,8 @@ struct ps_data {
>  	/* yes, this looks ugly, but guarantees that we can later use
>  	 * bitmap_empty :)
>  	 * NB: don't touch this bitmap, use sta_info_{set,clear}_tim_bit */
> -	u8 tim[sizeof(unsigned long) * BITS_TO_LONGS(IEEE80211_MAX_AID + 1)];
> +	u8 tim[sizeof(unsigned long) * BITS_TO_LONGS(IEEE80211_MAX_AID + 1)]
> +			__aligned(sizeof(unsigned long));

Care to send a proper patch? Otherwise I'll just re-do it and pick it up
that way ...

johannes
