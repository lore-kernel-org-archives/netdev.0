From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 0/5] forcedeth: several proposed updates for testing
Date: Sun, 07 Oct 2007 10:47:48 -0400
Message-ID: <4708F194.7080303@garzik.org>
References: <20071006151250.GA17020@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Yinghai Lu <yhlu.kernel@gmail.com>, Ingo Molnar <mingo@elte.hu>
To: netdev@vger.kernel.org, Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:46297 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752282AbXJGOrz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Oct 2007 10:47:55 -0400
In-Reply-To: <20071006151250.GA17020@havoc.gtf.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> The 'fe-lock' branch of
> git://git.kernel.org/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git fe-lock
> 
> contains the following changes that I would like to get tested:
> 
>       [netdrvr] forcedeth: make NAPI unconditional
>       [netdrvr] forcedeth: interrupt handling cleanup
>       [netdrvr] forcedeth: process TX completions using NAPI
>       [netdrvr] forcedeth: internal simplification and cleanups
>       [netdrvr] forcedeth: timer overhaul

OK, I've successfully tested patches 1-5 on an AMD64 system with

00:0a.0 Bridge: nVidia Corporation CK804 Ethernet Controller (rev a3)

A trivial s/napi/tx_napi/ fix must be applied to patch #3 (sent in 
separate email).  Once that is done, the patchset works flawlessly here, 
passing simple RX, TX, RX+TX TCP stress tests.

I never ran into any TX problems, of the type hinted at by the "Known 
bugs" section at the top of forcedeth.c.  Either (a) my chip does not 
have that bug, (b) my chip needs DEV_NEED_TIMERIRQ for other reasons, or 
(c) the issue is not a hardware issue but a driver bug that is now fixed.

I'm going to hope its (c), <grin>  But only testing will tell.

	Jeff


P.S.  Depending on when this gets fixed, you might have to revert 
net-2.6.24.git commit 5f5dace1ce001b24fb8286e09ffd3c4d2b547e09 ("[NET]: 
Various dst_ifdown routines to catch refcounting bugs").
