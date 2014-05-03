From: Luciano Coelho <luciano.coelho-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] cfg80211/mac80211: Fix warning on make xmldocs caused
 by cfg80211.h
Date: Sat, 03 May 2014 09:15:29 +0300
Message-ID: <1399097729.5873.2.camel@dubbel>
References: <1399041597-27409-1-git-send-email-standby24x7@gmail.com>
	 <1399041597-27409-2-git-send-email-standby24x7@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Masanari Iida <standby24x7-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1399041597-27409-2-git-send-email-standby24x7-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

On Fri, 2014-05-02 at 23:39 +0900, Masanari Iida wrote:
> Following error messages caused by wrong description.
> 
> Warning(include/net/cfg80211.h:461): No description found
> for parameter 'nl80211_iftype'
> 
> Change "iftype" to "nl80211_iftype" fix the errors.
> 
> Signed-off-by: Masanari Iida <standby24x7-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
>  include/net/cfg80211.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/include/net/cfg80211.h b/include/net/cfg80211.h
> index 7eae46c..695c562 100644
> --- a/include/net/cfg80211.h
> +++ b/include/net/cfg80211.h
> @@ -452,7 +452,7 @@ bool cfg80211_chandef_usable(struct wiphy *wiphy,
>   * cfg80211_chandef_dfs_required - checks if radar detection is required
>   * @wiphy: the wiphy to validate against
>   * @chandef: the channel definition to check
> - * @iftype: the interface type as specified in &enum nl80211_iftype
> + * @nl80211_iftype: the interface type as specified in &enum nl80211_iftype
>   * Returns:
>   *	1 if radar detection is required, 0 if it is not, < 0 on error
>   */

A better way to fix this would be to add "iftype" to the function
prototype, since we don't usually use nameless arguments:

diff --git a/include/net/cfg80211.h b/include/net/cfg80211.h
index 43c674e..f9e7373 100644
--- a/include/net/cfg80211.h
+++ b/include/net/cfg80211.h
@@ -458,7 +458,7 @@ bool cfg80211_chandef_usable(struct wiphy *wiphy,
  */
 int cfg80211_chandef_dfs_required(struct wiphy *wiphy,
                                  const struct cfg80211_chan_def *chandef,
-                                 enum nl80211_iftype);
+                                 enum nl80211_iftype iftype);
 
 /**
  * ieee80211_chandef_rate_flags - returns rate flags for a channel

--
Cheers,
Luca.


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
