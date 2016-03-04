From: Tim Shepard <shep-FrUbXkNCsVf2fBVCVOL8/A@public.gmane.org>
Subject: [PATCH RFC/RFT 0/2] ath9k: use mac80211 intermediate software queues
Date: Thu, 03 Mar 2016 20:06:12 -0500
Message-ID: <E1abeC4-0007p7-00@www.xplot.org>
Cc: michal.kazior-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org, johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	dave.taht-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org,
	andrewmcgr-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, apenwarr-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


Here is a patch in two parts to have ath9k make use the new
intermediate queues in mac80211.   It seems to work for me, but it
clearly needs more testing.

This should be useful to anyone who wants to try Michal's patch from
last week "mac80211: implement fq_codel for software queuing" as that
patch will not do anything unless you have a mac80211 driver that uses
the new mac80211 intermediate queues and indicates to mac80211 that
it does so by having a non-zero .wake_tx_queue method.

The first patch just renames the struct ath_txq in ath9k to be
struct ath_hwq and the renames the variables and fields holding a
pointer to it to be hwq  (instead of txq).

This first patch is IMHO needed because I had an earlier version of
this without renaming ath_txq and it was too mind bending to try and
keep straight which was ath9k's txq (which is per hardware queue)
and what was mac80211 txq (which is per station per tid).

The second patch changes ath9k to use the new mac80211 intermediate
software queues.

I left the existing ath9k software queue mechanisms in place. They
are used by the channel context code in some cases even for non-data
frames, and in any case it seemed like a safer first step to get this
working before removing code.  Yes, we should eventually clean this
up once this is tested and we figure out what the right way to do
the clean up.   I see little harm in leaving it stay for awhile.

I have not tried any testing with CONFIG_ATH9K_CHANNEL_CONTEXT=y and
I am not even sure what I would need to do to properly exercise that.

Please comment and/or test.

			-Tim Shepard
			 shep-FrUbXkNCsVf2fBVCVOL8/A@public.gmane.org
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
