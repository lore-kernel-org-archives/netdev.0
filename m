From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: RESEND, HTB(?) softlockup, vanilla 2.6.24
Date: Sun, 17 Feb 2008 10:11:47 +0100
Message-ID: <20080217091147.GA6093@ami.dom.local>
References: <20080213081318.M90354@visp.net.lb> <47B69824.4030405@gmail.com> <20080216102502.M41110@visp.net.lb> <20080216204519.GA2739@ami.dom.local> <20080216235419.M80874@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:35254 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753575AbYBQJIC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Feb 2008 04:08:02 -0500
Received: by ug-out-1314.google.com with SMTP id z38so129815ugc.16
        for <netdev@vger.kernel.org>; Sun, 17 Feb 2008 01:08:01 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080216235419.M80874@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 17, 2008 at 02:03:33AM +0200, Denys Fedoryshchenko wrote:
> Server is fully redundant now, so i apply patches (but i apply both, probably 
> it will make system more reliable somehow) and i enable required debug 
> options in kernel. So i will try to catch this bug few more times, probably 
> if it will generate more detailed info over netconsole it will be useful.

I guess you mean the patches mentioned in the "BUG/ spinlock lockup";
they could be useful, but we are not sure this is the same problem.
Anyway, if there are really stack overflows then we don't need any
bug report after this: with stack data corrupted they would show some
"false" problems. We need to find which code overflows and why. If you
want to debug this, then try to make this more reproducible e.g. with
CONFIG_4KSTACKS; anyway you should always turn on these options with
such problems: CONFIG_DEBUG_STACKOVERFLOW CONFIG_DEBUG_STACK_USAGE.

> Is there any project to dump console messages/kernel dump to disk? For 
...
I don't know, but there is probably something better: a project by
Intel to save this in some cpu memory (or something...). But again:
we don't need corrupted messages after stack overflow, and, if we
don't let for this, maybe these netconsole messages would be properly
printed and quite enough...

> I notice some code in MTD(CONFIG_MTD_OOPS), but i am not sure it is correct 
> and will work if i will setup MTD emulation for block device.

I'm not sure what do you mean by MTD emulation: it should be used with
MTD devices only, I presume?

Regards,
Jarek P.

PS: BTW, for HTB with actions I recommend my "sch_htb: htb_requeue fix",
available in 2.6.25-rc.
