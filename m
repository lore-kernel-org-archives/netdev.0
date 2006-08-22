From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 06/18] d80211:  rework rate control registration
Date: Tue, 22 Aug 2006 10:33:58 +0200
Message-ID: <1156235638.3621.17.camel@ux156>
References: <20060821074107.648561364@sipsolutions.net>
	 <20060821075159.839042963@sipsolutions.net>
	 <20060821211924.08f37437@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jouni Malinen <jkm@devicescape.com>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:63192 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1751181AbWHVId1
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Aug 2006 04:33:27 -0400
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20060821211924.08f37437@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-08-21 at 21:19 +0200, Jiri Benc wrote:

> This is not so easy. The locking around rate control modules is
> currently totally wrecked. I started cleaning this up before I left for
> vacation and haven't time to finish it yet.
> 
> My patches do:
> - rename of rate control files (rate_control.h => ieee80211_rate.h)
> - introduce a new ieee80211_rate.c file (I'm trying to gradually move
>   things out of the big ieee80211.c)
> - fix locking (Yes, it is broken. Yes, I can prove it.)
> - allow different rate control algorithm for each wiphy
> - proper and race-free rate control modules loading

I do the same here, actually, except for filenames. And then I simply
rely on module refcounting, which is fine IMHO.

And I'm pretty sure that with locking around all the
registration/unregistration it's fine. And I think that in this case,
having the list_head in the rate control ops structure is fine because
no rate control module can reasonably register it twice anyway.

However, I can drop the patch if you want to. I'm not particularly
attached to it ;)

> Sorry for not cleanly stating this before :-(

Do you have anything else you're working on? :P

johannes
