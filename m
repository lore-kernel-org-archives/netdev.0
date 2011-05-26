From: Laurent Riffard <laurent.riffard@free.fr>
Subject: Re: [BUG] netconsole broken by scheduler updates
Date: Thu, 26 May 2011 12:35:19 +0200 (CEST)
Message-ID: <alpine.DEB.2.02.1105261217240.5114@localhost6.localdomain6>
References: <4DDE1B7D.7080707@free.fr> <1306403308.1200.44.camel@twins>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Laurent Riffard <laurent.riffard@free.fr>, netdev@vger.kernel.org
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2-g21.free.fr ([212.27.42.2]:42473 "EHLO smtp2-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753319Ab1EZKf2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 May 2011 06:35:28 -0400
In-Reply-To: <1306403308.1200.44.camel@twins>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Thu, 26 May 2011, Peter Zijlstra wrote:
> On Thu, 2011-05-26 at 11:21 +0200, Laurent Riffard wrote:
>> Hi,
>>
>> Recently, netconsole was broken by some scheduler updates. Kernel hangs
>> on boot near the network card initialization. I noticed that it does
>> hang just where a "inconsistent lock state" message normally appears.
>>
>> I did a bisection : e4a52bcb9a18142d79e231b6733cabdbf2e67c1f is the
>> first bad commit.
>> commit e4a52bcb9a18142d79e231b6733cabdbf2e67c1f
>> Author: Peter Zijlstra <a.p.zijlstra@chello.nl>
>> Date:   Tue Apr 5 17:23:54 2011 +0200
>>
>>     sched: Remove rq->lock from the first half of ttwu()
>>
>>
>> Before this commit, kernel was booting succesfully despite the
>> "inconsistent lock state" message. After this commit, the kernel does
>> hang on boot, I have to push the reset button.
>
> Do you have CONFIG_HARDLOCKUP_DETECTOR=y, and do you get an NMI splat
> after some 10 seconds? It would be interesting to see where its stuck.

CONFIG_HARDLOCKUP_DETECTOR is not set for now. I'll give it a try.

> Also, are you very _very_ sure that lockdep message is a false positive?

I can't answer this question. I just know that before commit e4a52bcb9, 
the kernel was able to boot with netconsole despite this message.

Maybe some netconsole developper knows.
~~
laurent
