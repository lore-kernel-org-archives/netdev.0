From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] mac80211: Do not use sizeof() on pointer type
Date: Fri, 04 Sep 2015 14:24:48 +0200
Message-ID: <1441369488.1971.1.camel@sipsolutions.net>
References: <1440584534-27251-1-git-send-email-thierry.reding@gmail.com>
	 (sfid-20150826_122335_049759_FB67F67D)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Thierry Reding <thierry.reding@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1440584534-27251-1-git-send-email-thierry.reding@gmail.com> (sfid-20150826_122335_049759_FB67F67D)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2015-08-26 at 12:22 +0200, Thierry Reding wrote:
> From: Thierry Reding <treding@nvidia.com>
> 
> The rate_control_cap_mask() function takes a parameter mcs_mask, 
> which
> GCC will take to be u8 * even though it was declared with a fixed 
> size.
> This causes the following warning:
> 
> 	net/mac80211/rate.c: In function 'rate_control_cap_mask':
> 	net/mac80211/rate.c:719:25: warning: 'sizeof' on array 
> function parameter 'mcs_mask' will return size of 'u8 * {aka unsigned 
> char *}' [-Wsizeof-array-argument]
> 	   for (i = 0; i < sizeof(mcs_mask); i++)
> 	                         ^
> 	net/mac80211/rate.c:684:10: note: declared here
> 	       u8 mcs_mask[IEEE80211_HT_MCS_MASK_LEN],
> 	          ^
> 
> This can be easily fixed by using the IEEE80211_HT_MCS_MASK_LEN 
> directly
> within the loop condition.

Dunno if you (Thierry) saw all the discussion about this - but anyway,
applied, thanks.

johannes
