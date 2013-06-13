From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] alx: add a simple AR816x/AR817x device driver
Date: Fri, 14 Jun 2013 01:03:41 +0200
Message-ID: <20130613230341.GB16632@electric-eye.fr.zoreil.com>
References: <1370899609-13954-1-git-send-email-johannes@sipsolutions.net>
 <1371069202-21576-1-git-send-email-johannes@sipsolutions.net>
 <20130612230257.GB21234@electric-eye.fr.zoreil.com>
 <1371160342.8335.22.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, mcgrof@do-not-panic.com, kvalo@adurom.com,
	adrian.chadd@gmail.com
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:49388 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754451Ab3FMXDs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jun 2013 19:03:48 -0400
Content-Disposition: inline
In-Reply-To: <1371160342.8335.22.camel@jlt4.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Johannes Berg <johannes@sipsolutions.net> :
[...]
> Yes, I suppose I could, but is it worth it? It's held only for a very
> short amount of time to get the indirect register access correct. I
> don't really see any reason to prefer a mutex here?

Neither a spinlock nor a mutex should be needed but I have to sleep
before figuring it.

> Not sure what you mean by "push it in the common core methods"? I
> actually suspect that this lock can't ever be contended because the
> callers hold the RTNL anyway, but I don't really want to rely on just
> that.

Don't be shy :o)

[...]
> Hmm, yeah, I'll have to think about that. I don't really care about the
> performance all that much ... just want the device to work :-)

Ok. It's fine.

> Would I really want to rely on NAPI for error interrupts and the like
> though? I thought NAPI could potentially be deferred due to budget etc.

It will have to wait for ksoftirqd once its budget is exhausted.

If the irq and napi handlers don't share a lock, either they are racing
or the napi handler will be kicked on irq return.

I'll admit a bias towards some extra latency if it can buy user context
comfort.

-- 
Ueimor
