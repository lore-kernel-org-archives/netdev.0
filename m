From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 4/6] mac80211: clean up debugging
Date: Fri, 22 Jun 2012 16:43:23 +0200
Message-ID: <1340376203.4491.29.camel@jlt3.sipsolutions.net>
References: <1340370882-9258-1-git-send-email-johannes@sipsolutions.net>
	 <1340370882-9258-5-git-send-email-johannes@sipsolutions.net>
	 <1340375828.31821.11.camel@joe2Laptop>
	 (sfid-20120622_163725_973326_440DEFC6)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:37812 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933075Ab2FVOnZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jun 2012 10:43:25 -0400
In-Reply-To: <1340375828.31821.11.camel@joe2Laptop> (sfid-20120622_163725_973326_440DEFC6)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-06-22 at 07:37 -0700, Joe Perches wrote:
> On Fri, 2012-06-22 at 15:14 +0200, Johannes Berg wrote:
> > From: Johannes Berg <johannes.berg@intel.com>
> > 
> > There are a few things that make the debugging
> > in mac80211 painful:
> >  * pr_debug makes it require *both* Kconfig and
> >    dynamic configuration -- move to pr_info
> 
> pr_info can clutter the log.

Yes, please. We want this information printed unless it's disabled :-)

> >  * the macros still need trailing newlines
> 
> That's not a bad thing.

People are clearly forgetting them all the time. So I don't see any
reason to not add them in the macros if we're going to have macros
anyway.

> > @@ -317,7 +318,7 @@ ieee80211_agg_splice_packets(struct ieee80211_sub_if_data *sdata,
> >  	ieee80211_stop_queue_agg(sdata, tid);
> >  
> >  	if (WARN(!tid_tx, "TID %d gone but expected when splicing aggregates"
> > -			  " from the pending queue\n", tid))
> > +			  " from the pending queue", tid))
> 
> 
> defective.
> 
> Don't remove newlines in single modules.

Hm, I was under the impression WARN() didn't require a newline. Looks
like either that changed, or I was wrong -- will change this back.

> Using a single style _with_ a newline limits defects and
> limits the likely misuse in other styles.

I'd rather have double newlines once a while than missing ones. I've
seen a lot of bugs with missing newlines, which is rather annoying.

johannes
