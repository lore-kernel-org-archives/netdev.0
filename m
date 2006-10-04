From: Jiri Benc <jbenc@suse.cz>
Subject: Re: d80211: ieee80211_hw handlers in atomic context
Date: Wed, 4 Oct 2006 18:11:29 +0200
Message-ID: <20061004181129.408b4feb@griffin.suse.cz>
References: <4523DA7D.2080604@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Ivo Van Doorn <ivdoorn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:54192 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1161526AbWJDQLc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2006 12:11:32 -0400
To: Jan Kiszka <jan.kiszka@web.de>
In-Reply-To: <4523DA7D.2080604@web.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 04 Oct 2006 17:59:57 +0200, Jan Kiszka wrote:
> The reason is the invocation of rt2500usb's config handler in atomic
> context (timer handler). But this service requires schedulable context
> to submit and wait for some URBs.

Hm, I thought it had been fixed
(http://kernel.org/git/?p=linux/kernel/git/linville/wireless-dev.git;a=commit;h=d0d2b7a8ddc378ddea499f1537f6aea83d96d003).

We'll need to make something similar with sta_timer.

> That raises the question how to resolve the conflict best, at stack
> level by pushing such work into thread context (workqueues?) or at
> driver level by deferring these requests (if feasible at all without
> breaking the stack's timing)? What other callback handlers in
> ieee80211_hw can currently be called in atomic context? Given that all
> USB WLAN adapters will have to cope with this issue in some way, it may
> be wise to find a common solution.

It needs to be solved in the stack. ieee80211_hw->config callback should
return proper error code in a case of problems and this is not possible
when the work is deferred in the driver.

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
