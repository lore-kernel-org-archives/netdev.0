From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: [BUG] netconsole broken by scheduler updates
Date: Thu, 26 May 2011 11:48:28 +0200
Message-ID: <1306403308.1200.44.camel@twins>
References: <4DDE1B7D.7080707@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: Laurent Riffard <laurent.riffard@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canuck.infradead.org ([134.117.69.58]:35791 "EHLO
	canuck.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754534Ab1EZKMz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2011 06:12:55 -0400
In-Reply-To: <4DDE1B7D.7080707@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-05-26 at 11:21 +0200, Laurent Riffard wrote:
> Hi,
> 
> Recently, netconsole was broken by some scheduler updates. Kernel hangs 
> on boot near the network card initialization. I noticed that it does 
> hang just where a "inconsistent lock state" message normally appears.
> 
> I did a bisection : e4a52bcb9a18142d79e231b6733cabdbf2e67c1f is the 
> first bad commit.
> commit e4a52bcb9a18142d79e231b6733cabdbf2e67c1f
> Author: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Date:   Tue Apr 5 17:23:54 2011 +0200
> 
>     sched: Remove rq->lock from the first half of ttwu()
> 
> 
> Before this commit, kernel was booting succesfully despite the 
> "inconsistent lock state" message. After this commit, the kernel does 
> hang on boot, I have to push the reset button.

Do you have CONFIG_HARDLOCKUP_DETECTOR=y, and do you get an NMI splat
after some 10 seconds? It would be interesting to see where its stuck.

Also, are you very _very_ sure that lockdep message is a false positive?

