From: Zachary Amsden <zach@vmware.com>
Subject: Re: [patch 13/26] Xen-paravirt_ops: Consistently wrap paravirt ops
 callsites to make them patchable
Date: Tue, 20 Mar 2007 19:43:59 -0800
Message-ID: <4600A9FF.3010309@vmware.com>
References: <20070316.023331.59468179.davem@davemloft.net> <45FB005D.9060809@goop.org> <1174127638.8897.75.camel@localhost.localdomain> <20070318.003309.71088169.davem@davemloft.net> <20070318120814.GA45869@muc.de> <1174272469.11680.23.camel@localhost.localdomain> <m1648xxf93.fsf@ebiederm.dsl.xmission.com> <Pine.LNX.4.64.0703191134190.6730@woody.linux-foundation.org> <1174348905.11680.54.camel@localhost.localdomain> <45FF4043.4000805@vmware.com> <45FF770C.7050301@goop.org> <Pine.LNX.4.64.0703200805450.6730@woody.linux-foundation.org> <m1mz27sy82.fsf@ebiederm.dsl.xmission.com> <Pine.LNX.4.64.0703200903500.6730@woody.linux-foundation.org> <46000C7E.4070001@goop.org> <46005B89.5070301@vmware.com> <Pine.LNX.4.64.0703201715470.6730@woody.linux-foundation.org> <46009E42.30400@vmware.com> <Pine.LNX.4.64.0703201912270.6730@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeremy Fitzhardinge <jeremy@goop.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Rusty Russell <rusty@rustcorp.com.au>, Andi Kleen <ak@muc.de>,
	David Miller <davem@davemloft.net>, mingo@elte.hu,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	virtualization@lists.osdl.org, xen-devel@lists.xensource.com,
	chrisw@sous-sol.org, anthony@codemonkey.ws, netdev@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-1.vmware.com ([65.113.40.141]:50132 "EHLO
	smtp-outbound-1.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752504AbXCUCne (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2007 22:43:34 -0400
In-Reply-To: <Pine.LNX.4.64.0703201912270.6730@woody.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linus Torvalds wrote:
> On Tue, 20 Mar 2007, Zachary Amsden wrote:
>   
>> Actually, I was thinking the irq handlers would just not mess around with
>> eflags on the stack, just call the chip to ack the interrupt and re-enable
>> hardware interrupts when they left, since that is free anyway with the iret.
>>     
>
> No can do. Think level-triggered. You *need* to disable the interrupt, and 
> disabling it at the CPU is the easiest approach. Even so, you need to 
> worry about SMP and screaming interrupts at all CPU's, but if you don't 
> ack it to the IO-APIC until later, that should be ok (alternatively, you 
> need to just mask-and-ack the irq controller).
>   

Well, you can keep it masked, but a more important point is that I've 
entirely neglected local interrupts.  This might work for IRQs, but for 
local timer or thermal or IPIs, using the tasklet based replay simply 
will not work.

> One of the advantages of doing that is that you only ever have a queue of 
> one single entry, which then makes it easier to do the replay.
>   

Yes.  Unfortunately now both do_IRQ and all the smp_foo interrupt 
handlers need to detect and queue for replay, but fortunately they all 
have the interrupt number conveniently on the stack.

Zach
