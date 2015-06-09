From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 4.1] cfg80211: wext: clear sinfo struct before calling
 driver
Date: Tue, 09 Jun 2015 13:54:42 -0700 (PDT)
Message-ID: <20150609.135442.1357702617373015039.davem@davemloft.net>
References: <1433878544-10749-1-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	gerrit-VsoRXqaLlyfQzY9nttDBhA@public.gmane.org, alexkaltsas-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1433878544-10749-1-git-send-email-johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Date: Tue,  9 Jun 2015 21:35:44 +0200

> From: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> 
> Until recently, mac80211 overwrote all the statistics it could
> provide when getting called, but it now relies on the struct
> having been zeroed by the caller. This was always the case in
> nl80211, but wext used a static struct which could even cause
> values from one device leak to another.
> 
> Using a static struct is OK (as even documented in a comment)
> since the whole usage of this function and its return value is
> always locked under RTNL. Not clearing the struct for calling
> the driver has always been wrong though, since drivers were
> free to only fill values they could report, so calling this
> for one device and then for another would always have leaked
> values from one to the other.
> 
> Fix this by initializing the structure in question before the
> driver method call.
> 
> This fixes https://bugzilla.kernel.org/show_bug.cgi?id=99691
> 
> Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Reported-by: Gerrit Renker <gerrit-VsoRXqaLlyfQzY9nttDBhA@public.gmane.org>
> Reported-by: Alexander Kaltsas <alexkaltsas-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Signed-off-by: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> ---
> Dave, would you mind applying this patch directly? It seems a
> bit pointless to send a pull request for a single patch again.

Sure, I'll do that right now.

Thanks Johannes.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
