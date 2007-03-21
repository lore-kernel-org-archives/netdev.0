From: Zachary Amsden <zach@vmware.com>
Subject: Re: [patch 13/26] Xen-paravirt_ops: Consistently wrap paravirt ops
 callsites to make them patchable
Date: Tue, 20 Mar 2007 17:14:45 -0800
Message-ID: <46008705.6010007@vmware.com>
References: <1174272469.11680.23.camel@localhost.localdomain> <m1648xxf93.fsf@ebiederm.dsl.xmission.com> <Pine.LNX.4.64.0703191134190.6730@woody.linux-foundation.org> <1174348905.11680.54.camel@localhost.localdomain> <45FF4043.4000805@vmware.com> <45FF770C.7050301@goop.org> <Pine.LNX.4.64.0703200805450.6730@woody.linux-foundation.org> <m1mz27sy82.fsf@ebiederm.dsl.xmission.com> <Pine.LNX.4.64.0703200903500.6730@woody.linux-foundation.org> <46000C7E.4070001@goop.org> <20070320224324.GL10459@waste.org> <46006963.1020401@vmware.com> <46006F66.4030901@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Matt Mackall <mpm@selenic.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Rusty Russell <rusty@rustcorp.com.au>, Andi Kleen <ak@muc.de>,
	David Miller <davem@davemloft.net>, mingo@elte.hu,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	virtualization@lists.osdl.org, xen-devel@lists.xensource.com,
	chrisw@sous-sol.org, anthony@codemonkey.ws, netdev@vger.kernel.org
To: Jeremy Fitzhardinge <jeremy@goop.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-1.vmware.com ([65.113.40.141]:42948 "EHLO
	smtp-outbound-1.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752034AbXCUAOU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2007 20:14:20 -0400
In-Reply-To: <46006F66.4030901@goop.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeremy Fitzhardinge wrote:
> Zachary Amsden wrote:
>   
>> I think Jeremy's idea was to have interrupt handlers leave interrupts
>> disabled on exit if pda.intr_mask was set.  In which case, they would
>> bypass all work and we could never get preempted.
>>     
>
> Yes, I was worried that if we left the isr without actually handling the
> interrupt, it would still be asserted and we'd just get interrupted
> again.  The idea is that we avoid touching cli/sti for the common case
> of no interrupts while interrupts are disabled, but we'd still need to
> fall back to using them if an interrupt becomes pending.
>
>   
>> I don't think leaving hardware interrupts disabled for such a long
>> time is good though. 
>>     
>
> How long?  It would be no longer than now, and possibly less, wouldn't it?
>   

Hmm.  Perhaps.  Something about the asymmetry bothers me alot though.

Zach

