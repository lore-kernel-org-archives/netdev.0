From: Arjan van de Ven <arjan@linux.intel.com>
Subject: Re: [patch 7/8] lock validator: fix ns83820.c irq-flags bug
Date: Sun, 11 Jun 2006 09:12:17 -0700
Message-ID: <448C40E1.8080705@linux.intel.com>
References: <200606090519.k595JmDG032032@shell0.pdx.osdl.net> <448C2EEE.1020405@garzik.org> <448C2FFE.3010002@linux.intel.com> <448C4021.80102@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, netdev@vger.kernel.org, mingo@elte.hu,
	bcrl@kvack.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr18.intel.com ([134.134.136.17]:36739 "EHLO
	orsfmr003.jf.intel.com") by vger.kernel.org with ESMTP
	id S932119AbWFKQNN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 11 Jun 2006 12:13:13 -0400
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <448C4021.80102@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Arjan van de Ven wrote:
>> Jeff Garzik wrote:
>>> The driver's locking is definitely wrong, but I don't think this is 
>>> the fix, 
>>
>> it's an obvious correct fix in the correctness sense though...
>>
>>>
>>> Jesus, the locking here is awful.  No wonder there are bugs.
>>
>>
>> ... which given that fact, is for 2.6.17 probably the right thing, 
>> pending
>> a nicer fix for 2.6.18
> 
> I disagree, the patch is wrong too.

wrong as in "not quite optimal", not wrong as in "buggy".

> For normal PCI hardware, the in-ISR paths should all use spin_lock(), 

only for per hardware locks obviously, not for per driver locks ;)


you are right that it's a lot nicer to do what you describe. No argument
from me on that part. But to call it "wrong" or "incorrect" is not quite
ok.  In terms of changing/fixing the approach we did was the simplest one.
Not the "make it look nice" one. Fix it by making the bug go away in the light
of a LOT of fishy locking.

You can demand that we first fix all the fishy locking first, and I can even
in part agree with that, but for -stable and 2.6.17 that is obviously out
of scope while a simple "make the bug go away" fix is not.

