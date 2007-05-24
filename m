From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [Kgdb-bugreport] [PATCH] 8139too: harden against TX ring overflow
Date: Thu, 24 May 2007 17:44:11 -0400
Message-ID: <4656072B.40801@garzik.org>
References: <200704052350.59464.sshtylyov@ru.mvista.com> <465603B9.90401@ru.mvista.com> <4656060A.6000102@garzik.org> <4656073E.1030804@ru.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mhuth@mvista.com,
	kgdb-bugreport@lists.sourceforge.net
To: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:48342 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751027AbXEXVoN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 May 2007 17:44:13 -0400
In-Reply-To: <4656073E.1030804@ru.mvista.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sergei Shtylyov wrote:
> Jeff Garzik wrote:
> 
>>>> This driver's 4-packet deep TX queue is too sensible to the 
>>>> "careless" callers
>>>> ignoring its state (like netpoll in trapped mode), so add "queue 
>>>> full" check at
>>>> the start of the hard_start_xmit() method (only under #ifndef 
>>>> RTL8139_NDEBUG,
>>>> otherwise the queue will get stuck once dirty pointer gets out of 
>>>> sync); switch
>>>> to using appropriate mnemonics for the return values while at it.
>>>> Also, the out-of-sync dirty pointer check is misplaced in 
>>>> rtl8139_tx_interrupt()
>>>> which causes TX descriptors to be inspected more than once in case 
>>>> the pointer
>>>> really gets out-of-sync (and incrementing the dirty pointer always 
>>>> by 4 is just
>>>> not enough, e.g. KGDBoE managed to stuff 20+ extra buffers into the 
>>>> queue) --
>>>> place it before the loop and limit the loop to only look through 4 
>>>> descriptors
>>>> at most, so that already overwritten descriptors are just not counted.
> 
>>>> Signed-off-by: Sergei Shtylyov <sshtylyov@ru.mvista.com>
> 
>>>    Jeff, do you have any opinion on this patch?
> 
>> The out-of-sync dirty pointer check is leftover boilerplate, and not 
>> really indicative of anything except for some code to be removed.
> 
>> As for the other stuff, I would say "fix the caller".  We don't need 
>> to hack every driver for cases where netpoll is being dumb.
> 
>    Caller's been fixed now. So, I read that as reject. :-)

Mostly.  You're still welcome to remove the silly boilerplate checks...

And ->hard_start_xmit() return value update(s) were sane.

	Jeff



