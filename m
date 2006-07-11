From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] d80211: make sleeping in hw->config possible #2
Date: Tue, 11 Jul 2006 02:31:00 -0700
Message-ID: <20060711023100.6d117264.akpm@osdl.org>
References: <200607110054.36520.mb@bu3sch.de>
	<20060710212536.5a223977.akpm@osdl.org>
	<200607111111.28040.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, jbenc@suse.cz, netdev@vger.kernel.org,
	bcm43xx-dev@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:18665 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750814AbWGKJbT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Jul 2006 05:31:19 -0400
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200607111111.28040.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 11 Jul 2006 11:11:27 +0200
Michael Buesch <mb@bu3sch.de> wrote:

> But I think the following is also broken in the old code:
> A wq is not pending anymore, but just executing (before it reschedules itself).
> I think that would also loop forever. I don't think that's what we want.
> Because we can't really keep track of _this_.

The present implementation assumes that the handler will re-arm itself.

I agree that extending that makes sense.  But beware that it's easy to
leave subtle holes in this logic.  Needs careful thought to get right.

