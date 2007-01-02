From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] d80211: Fix inconsistent sta_lock usage
Date: Tue, 2 Jan 2007 16:22:01 +0000
Message-ID: <20070102162201.GA28457@infradead.org>
References: <45996CBA.8020307@web.de> <a32f33a40701020730n773d7ed8pe99d98ecc7b96a0e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jan Kiszka <jan.kiszka@web.de>, Jiri Benc <jbenc@suse.cz>,
	netdev@vger.kernel.org, rt2400-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:37738 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753569AbXABQWE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jan 2007 11:22:04 -0500
To: Ivo Van Doorn <ivdoorn@gmail.com>
Content-Disposition: inline
In-Reply-To: <a32f33a40701020730n773d7ed8pe99d98ecc7b96a0e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 02, 2007 at 04:30:41PM +0100, Ivo Van Doorn wrote:
> +static inline void __bss_tim_set(struct ieee80211_local *local,
> +				 struct ieee80211_if_ap *bss, int aid)
> +{
> +	bss->tim[(aid)/8] |= 1<<((aid) % 8);
> +}

This really screams to be converted to __set_bit.  Also the local
argument is entirely unused.  I'd probaby not even add a helper for
this but just opencode it as:

	__set_bit(&bss->time, aid);

> +static inline void __bss_tim_clear(struct ieee80211_local *local,
> +				   struct ieee80211_if_ap *bss, int aid)
> +{
> +	bss->tim[(aid)/8] &= !(1<<((aid) % 8));

Similarly this should just be __clear_bit

