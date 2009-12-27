From: Avi Kivity <avi@redhat.com>
Subject: Re: [GIT PULL] AlacrityVM guest drivers for 2.6.33
Date: Sun, 27 Dec 2009 15:49:06 +0200
Message-ID: <4B3765D2.5020805@redhat.com>
References: <4B1D4F29.8020309@gmail.com> <87637zdy9g.fsf@basil.nowhere.org> <4B30E654.40702@codemonkey.ws> <200912221701.56840.bzolnier@gmail.com> <4B30F214.80206@codemonkey.ws> <20091223065129.GA19600@elte.hu> <4B3248F9.5030504@gmail.com> <4B327F3A.9020101@redhat.com> <4B328535.5040105@redhat.com> <4B33361E.3000605@gmail.com> <4B3729ED.50006@redhat.com> <4B376276.3020105@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>,
	Anthony Liguori <anthony@codemonkey.ws>,
	Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>,
	Andi Kleen <andi@firstfloor.org>, kvm@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	torvalds@linux-foundation.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org,
	"alacrityvm-devel@lists.sourceforge.net"
	<alacrityvm-devel@lists.sourceforge.net>
To: Gregory Haskins <gregory.haskins@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28667 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751972AbZL0Ntp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Dec 2009 08:49:45 -0500
In-Reply-To: <4B376276.3020105@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/27/2009 03:34 PM, Gregory Haskins wrote:
> On 12/27/09 4:33 AM, Avi Kivity wrote:
>    
>> On 12/24/2009 11:36 AM, Gregory Haskins wrote:
>>      
>>>> As a twist on this, the VMware paravirt driver interface is so
>>>> hardware-like that they're getting hardware vendors to supply cards that
>>>> implement it.  Try that with a pure software approach.
>>>>
>>>>          
>>> Any hardware engineer (myself included) will tell you that, generally
>>> speaking, what you can do in hardware you can do in software (think of
>>> what QEMU does today, for instance).  It's purely a cost/performance
>>> tradeoff.
>>>
>>> I can at least tell you that is true of vbus.  Anything on the vbus side
>>> would be equally eligible for a hardware implementation, though there is
>>> not reason to do this today since we have equivalent functionality in
>>> baremetal already.
>>>        
>> There's a huge difference in the probability of vmware getting cards to
>> their spec, or x86 vendors improving interrupt delivery to guests,
>> compared to vbus being implemented in hardware.
>>      
> Thats not relevant, however.  I said in the original quote that you
> snipped that I made it a software design on purpose, and you tried to
> somehow paint that as a negative because vmware made theirs
> "hardware-like" and you implied it could not be done with my approach
> with the statement "try that with a pure software approach".  And the
> bottom line is that the statement is incorrect and/or misleading.
>    

It's not incorrect.  VMware stuck to the pci specs and as a result they 
can have hardware implement their virtual NIC protocol.  For vbus this 
is much harder to do since you need a side-channel between different 
cards to coordinate interrupt delivery.  In theory you can do eveything 
if you don't consider practicalities.

That's a digression, though, I'm not suggesting we'll see virtio 
hardware or that this is a virtio/pci advantage vs. vbus.  It's an 
anecdote showing that sticking with specs has its advantages.

wrt pci vs vbus, the difference is in the ability to use improvements in 
interrupt delivery accelerations in virt hardware.  If this happens, 
virtio/pci can immediately take advantage of it, while vbus has to stick 
with software delivery for backward compatibility, and all that code 
becomes a useless support burden.

As an example of what hardware can do when it really sets its mind to 
it, s390 can IPI from vcpu to vcpu without exiting to the host.

>>> The only motiviation is if you wanted to preserve
>>> ABI etc, which is what vmware is presumably after.  However, I am not
>>> advocating this as necessary at this juncture.
>>>
>>>        
>> Maybe AlacrityVM users don't care about compatibility, but my users do.
>>      
> Again, not relevant to this thread.  Making your interface
> "hardware-like" buys you nothing in the end, as you ultimately need to
> load drivers in the guest either way, and any major OS lets you extend
> both devices and buses with relative ease.  The only counter example
> would be if you truly were "hardware-exactly" like e1000 emulation, but
> we already know that this means it is hardware centric and not
> "exit-rate aware" and would perform poorly.  Otherwise "compatible" is
> purely a point on the time line (for instance, the moment virtio-pci ABI
> shipped), not an architectural description such as "hardware-like".
>    

True, not related to the thread.  But it is a problem.  The difference 
between virtio and vbus here is that virtio is already deployed and its 
users expect not to reinstall drivers [1].  Before virtio existed, 
people could not deploy performance sensitive applications on kvm.  Now 
that it exists, we have to support it without requiring users to touch 
their guests.

That means that without proof that virtio cannot be scaled, we'll keep 
supporting and extending it.


[1] Another difference is the requirement for writing a "bus driver" for 
every supported guest, which means dealing with icky bits like hotplug.

-- 
error compiling committee.c: too many arguments to function

