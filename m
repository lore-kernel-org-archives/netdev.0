From: "Jouni Malinen" <jkm@devicescape.com>
Subject: Re: [PATCH] ieee80211: quiet TKIP and CCMP replay messages for  identical TSCs
Date: Thu, 28 Sep 2006 09:02:40 -0700
Message-ID: <20060928160240.GB9615@instant802.com>
References: <4517FA78.mailH4P11L3ZE@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-25.dex002.intermedia.net ([64.78.21.107]:31454 "EHLO
	dhost002-25.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S1751660AbWI1QCp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Sep 2006 12:02:45 -0400
To: Larry Finger <Larry.Finger@lwfinger.net>
Content-Disposition: inline
In-Reply-To: <4517FA78.mailH4P11L3ZE@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 25, 2006 at 10:49:12AM -0500, Larry Finger wrote:

> When using TKIP and CCMP for wireless encryption with ieee80211, the logs get filled with useless
> replay messages where the previous and received TSC are identical. This change deletes
> the log message for this case, but still prints the message when there are major differences
> in the TSC's.

NAK.

These are not useless messages; they are more or less always indication
of a broken implementation. I have nothing against hiding the messages
by default, but there should be an easy mechanism for noticing that this
is the reason for connection not working..

> --- wireless-2.6.orig/net/ieee80211/ieee80211_crypt_tkip.c
> @@ -394,7 +394,7 @@ static inline int tkip_replay_check(u32 
> -	    (iv32_n == iv32_o && iv16_n <= iv16_o))
> +	    (iv32_n == iv32_o && iv16_n < iv16_o))

> --- wireless-2.6.orig/net/ieee80211/ieee80211_crypt_ccmp.c
> @@ -287,7 +287,7 @@ static inline int ccmp_replay_check(u8 *
> -	    (iv32_n == iv32_o && iv16_n <= iv16_o))
> +	    (iv32_n == iv32_o && iv16_n < iv16_o))

These changes would break replay protection and must not be applied.
This is opening a security problem, not just limiting when something is
being printed out.

I would be more open to adding this extra condition for just the printk,
i.e., changing net_ratelimit() to net_ratelimit() && (iv32 and iv16 are
same). Even this is a case that should not really happen unless
something is broken since IEEE 802.11 duplicate detection should have
filtered the frames before (and it should be fixed if it did not do its
job correctly).

-- 
Jouni Malinen                                            PGP id EFC895FA
