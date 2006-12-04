From: Kenzo Iwami <k-iwami@cj.jp.nec.com>
Subject: Re: watchdog timeout panic in e1000 driver
Date: Mon, 04 Dec 2006 18:14:37 +0900
Message-ID: <4573E6FD.3030905@cj.jp.nec.com>
References: <36D9DB17C6DE9E40B059440DB8D95F52013ABFE9@orsmsx418.amr.corp.intel.com> <4562D207.60301@cj.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	Shaw Vrana <shaw@vranix.com>, netdev@vger.kernel.org,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from TYO201.gate.nec.co.jp ([202.32.8.193]:15772 "EHLO
	tyo201.gate.nec.co.jp") by vger.kernel.org with ESMTP
	id S1759858AbWLDJOt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Dec 2006 04:14:49 -0500
To: Kenzo Iwami <k-iwami@cj.jp.nec.com>
In-Reply-To: <4562D207.60301@cj.jp.nec.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

>> Doesn't this just mean that we need a spinlock or some other kind of
>> semaphore around acquiring, using, and releasing this resource?  We keep
>> going around and around about this but I'm pretty sure spinlocks are
>> meant to be able to solve exactly this issue.
>>
>> The problem is going to get considerably more nasty if we need to hold a
>> spinlock with interrupts disabled for a significant amount of time, at
>> which point a semaphore of some kind with a spinlock around it would
>> seem to be more useful.
> 
> Even if spin_lock() was used to protect this resource, it is still possible
> for an interrupt to kick in and call e1000_watchdog. In this case,
> e1000_get_software_semaphore() will be called from within the interrupt
> handler and the problem will still occur.
> 
> In order to solve this problem, interrupt should be disabled (for example,
> spin_lock_irqsave).
> The interrupt handler can't run while the process is holding this resource,
> and this problem doesn't occur.
> 
>> I'll work with Auke to see if we can come up with another try.
> 
> Do you have any updates about your test code?

Does the fix I previously proposed have problems?
If it does, I'd like to help find investigate another fix to solve
this problem.

-- 
  Kenzo Iwami (k-iwami@cj.jp.nec.com)
