From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH 06/18] d80211:  rework rate control registration
Date: Mon, 21 Aug 2006 21:19:24 +0200
Message-ID: <20060821211924.08f37437@griffin.suse.cz>
References: <20060821074107.648561364@sipsolutions.net>
	<20060821075159.839042963@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jouni Malinen <jkm@devicescape.com>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:27356 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1750824AbWHUTT1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2006 15:19:27 -0400
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <20060821075159.839042963@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 21 Aug 2006 09:41:13 +0200, Johannes Berg wrote:
> Contrary to what Jiri said, proper rate control module refcounting
> is much easier than allowing rate control changes on-the-fly...
> This patch implements only the former along with cleanups.
> Note that the diff between rate_control.c and rate_control_simple.c
> is small (modulo fixing indenting etc.), but I wanted to rename the
> file to more accurately reflect what it is.

This is not so easy. The locking around rate control modules is
currently totally wrecked. I started cleaning this up before I left for
vacation and haven't time to finish it yet.

My patches do:
- rename of rate control files (rate_control.h => ieee80211_rate.h)
- introduce a new ieee80211_rate.c file (I'm trying to gradually move
  things out of the big ieee80211.c)
- fix locking (Yes, it is broken. Yes, I can prove it.)
- allow different rate control algorithm for each wiphy
- proper and race-free rate control modules loading

Changing of rate control algorithm on the fly is still not supported,
but the infrastructure for it is (hopefully) laid.

Sorry for not cleanly stating this before :-(

 Jiri

-- 
Jiri Benc
SUSE Labs
