From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] nl80211: fix dumpit error path RTNL deadlocks
Date: Wed, 15 Mar 2017 14:59:02 -0700 (PDT)
Message-ID: <20170315.145902.1038598966216203408.davem@davemloft.net>
References: <20170315132913.26088-1-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        sowmini.varadhan-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, dvyukov-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
        johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170315132913.26088-1-johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Date: Wed, 15 Mar 2017 14:29:13 +0100

> From: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> 
> Sowmini pointed out Dmitry's RTNL deadlock report to me, and it turns out
> to be perfectly accurate - there are various error paths that miss unlock
> of the RTNL.
> 
> To fix those, change the locking a bit to not be conditional in all those
> nl80211_prepare_*_dump() functions, but make those require the RTNL to
> start with, and fix the buggy error paths. This also let me use sparse
> (by appropriately overriding the rtnl_lock/rtnl_unlock functions) to
> validate the changes.
> 
> Reported-by: Sowmini Varadhan <sowmini.varadhan-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
> Reported-by: Dmitry Vyukov <dvyukov-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

Johannes, I assume I will get this in a future pull request?
