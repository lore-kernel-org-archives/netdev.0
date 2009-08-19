From: Avi Kivity <avi@redhat.com>
Subject: Re: [PATCH v3 3/6] vbus: add a "vbus-proxy" bus model for vbus_driver
 objects
Date: Wed, 19 Aug 2009 17:35:59 +0300
Message-ID: <4A8C0DCF.8080400@redhat.com>
References: <20090814154125.26116.70709.stgit@dev.haskins.net> <20090814154308.26116.46980.stgit@dev.haskins.net> <20090815103243.GA26749@elte.hu> <4A870964.9090408@codemonkey.ws> <4A8965E0.8050608@gmail.com> <4A89FF08.30509@codemonkey.ws> <4A8AA9BD.2070909@gmail.com> <4A8AB076.6080906@redhat.com> <4A8ACE1F.6020402@gmail.com> <20090818161434.GA15884@elte.hu> <4A8B7F17.6050100@gmail.com> <4A8B8C11.9030800@redhat.com> <4A8BFDD7.4040900@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>,
	Anthony Liguori <anthony@codemonkey.ws>, kvm@vger.kernel.org,
	alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>,
	"Ira W. Snyder" <iws@ovro.caltech.edu>
To: Gregory Haskins <gregory.haskins@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:58926 "EHLO mx2.redhat.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751961AbZHSOgY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Aug 2009 10:36:24 -0400
In-Reply-To: <4A8BFDD7.4040900@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/19/2009 04:27 PM, Gregory Haskins wrote:
>>   There's no inherent performance
>> problem in pci.  The vbus approach has inherent problems (the biggest of
>> which is compatibility
>>      
> Trying to be backwards compatible in all dimensions is not a design
> goal, as already stated.
>    

It's important to me.  If you ignore what's important to me don't expect 
me to support your code.

>
> , the second managability).
>    
>>      
> Where are the management problems?
>    

Requiring root, negotiation in the kernel (making it harder to set up a 
compatible "migration pool", but wait, you don't care about migration 
either.


> No, you have shown me that you disagree.  I'm sorry, but do not assume
> they are the same.

[...]

> I'm sorry, but thats just plain false.
>    

Don't you mean, "I disagree but that's completely different from you 
being wrong".

>> Existing guests (Linux and
>> Windows) which support virtio will cease to work if the host moves to
>> vbus-virtio.
>>      
> Sigh...please re-read "fact" section.  And even if this work is accepted
> upstream as it is, how you configure the host and guest is just that: a
> configuration.  If your guest and host both speak vbus, use it.  If they
> don't, don't use it.  Simple as that.  Saying anything else is just more
> FUD, and I can say the same thing about a variety of other configuration
> options currently available.
>    

The host, yes.  The guest, no.  I have RHEL 5.3 and Windows guests that 
work with virtio now, and I'd like to keep it that way.  Given that I 
need to keep the current virtio-net/pci ABI, I have no motivation to add 
other ABIs.  Given that host userspace configuration works, I have no 
motivation to move it into a kernel configfs/vbus based system.  The 
only thing that's hurting me is virtio-net's performance problems and 
we're addressing it by moving the smallest possible component into the 
kernel: vhost-net.


>> Existing hosts (running virtio-pci) won't be able to talk
>> to newer guests running virtio-vbus.  The patch doesn't improve
>> performance without the entire vbus stack in the host kernel and a
>> vbus-virtio-net-host host kernel driver.
>>      
> <rewind years=2>Existing hosts (running realtek emulation) won't be able
> to talk to newer guests running virtio-net.  Virtio-net doesn't do
> anything to improve realtek emulation without the entire virtio stack in
> the host.</rewind>
>
> You gotta start somewhere.   You're argument buys you nothing other than
> backwards compat, which I've already stated is not a specific goal here.
>   I am not against "modprobe vbus-pcibridge", and I am sure there are
> users out that that do not object to this either.
>    

Two years ago we had something that was set in stone and had a very 
limited performance future.  That's not the case now.  If every two 
years we start from scratch we'll be in a pretty pickle fairly soon.

virtio-net/pci is here to stay.  I see no convincing reason to pour 
efforts into a competitor and then have to support both.

>> Perhaps if you posted everything needed to make vbus-virtio work and
>> perform we could compare that to vhost-net and you'll see another reason
>> why vhost-net is the better approach.
>>      
> Yet, you must recognize that an alternative outcome is that we can look
> at issues outside of virtio-net on KVM and perhaps you will see vbus is
> a better approach.
>    

We won't know until that experiment takes place.

>>> You are also wrong to say that I didn't try to avoid creating a
>>> downstream effort first.   I believe the public record of the mailing
>>> lists will back me up that I tried politely pushing this directly though
>>> kvm first.  It was only after Avi recently informed me that they would
>>> be building their own version of an in-kernel backend in lieu of working
>>> with me to adapt vbus to their needs that I decided to put my own
>>> project together.
>>>
>>>        
>> There's no way we can adapt vbus to our needs.
>>      
> Really?  Did you ever bother to ask how?  I'm pretty sure you can.  And
> if you couldn't, I would have considered changes to make it work.
>    

Our needs are: compatibility, live migration, Windows, managebility 
(nonroot, userspace control over configuration).  Non-requirements but 
highly desirable: minimal kernel impact.

>> Don't you think we'd preferred it rather than writing our own?
>>      
> Honestly, I am not so sure based on your responses.
>    

Does your experience indicate that I reject patches from others in 
favour of writing my own?

Look for your own name in the kernel's git log.

> I've already listed numerous examples on why I advocate vbus over PCI,
> and have already stated I am not competing against virtio.
>    

Well, your examples didn't convince me, and vbus's deficiencies 
(compatibility, live migration, Windows, managebility, kernel impact) 
aren't helping.

>> Showing some of those non-virt uses, for example.
>>      
> Actually, Ira's chassis discussed earlier is a classic example.  Vbus
> actually fits neatly into his model, I believe (and much better than the
> vhost proposals, IMO).
>
> Basically, IMO we want to invert Ira's bus (so that the PPC boards see
> host-based devices, instead of the other way around).  You write a
> connector that transports the vbus verbs over the PCI link.  You write a
> udev rule that responds to the PPC board "arrival" event to create a new
> vbus container, and assign the board to that context.
>    

It's not inverted at all.  vhost-net corresponds to the device side, 
where a real NIC's DMA engine lives, while virtio-net is the guest side 
which drives the device and talks only to its main memory (and device 
registers).  It may seem backwards but it's quite natural when you 
consider DMA.

If you wish to push vbus for non-virt uses, I have nothing to say.  If 
you wish to push vbus for some other hypervisor (like AlacrityVM), 
that's the other hypervisor's maintainer's turf.  But vbus as I 
understand it doesn't suit kvm's needs (compatibility, live migration, 
Windows, managebility, kernel impact).

>> The fact that your only user duplicates existing functionality doesn't help.
>>      
> Certainly at some level, that is true and is unfortunate, I agree.  In
> retrospect, I wish I started with something non-overlapping with virtio
> as the demo, just to avoid this aspect of controversy.
>
> At another level, its the highest-performance 802.x interface for KVM at
> the moment, since we still have not seen benchmarks for vhost.  Given
> that I have spent a lot of time lately optimizing KVM, I can tell you
> its not trivial to get it to work better than the userspace virtio.
> Michael is clearly a smart guy, so the odds are in his favor.  But do
> not count your chickens before they hatch, because its not guaranteed
> success.
>    

Well the latency numbers seem to match (after normalizing for host-host 
baseline).  Obviously throughput needs more work, but I have confidence 
we'll see pretty good results.

> Long story short, my patches are not duplicative on all levels (i.e.
> performance).  Its just another ethernet driver, of which there are
> probably hundreds of alternatives in the kernel already.  You could also
> argue that we already have multiple models in qemu (realtek, e1000,
> virtio-net, etc) so this is not without precedent.  So really all this
> "fragmentation" talk is FUD.  Lets stay on-point, please.
>    

It's not FUD and please talk technical, not throw words around.  If 
there are a limited number of kvm developers, then every new device 
dilutes the effort.  Further, e1000 and friends don't need drivers for a 
bunch of OSs, v* do.

> Can we talk more about that at some point?  I think you will see its not
> some "evil, heavy duty" infrastructure that some comments seem to be
> trying to paint it as.  I think its similar in concept to what you need
> to do for a vhost like design, but (with all due respect to Michael) a
> little bit more thought into the necessary abstraction points to allow
> broader application.
>    

vhost-net only pumps the rings.  It leaves everything else for 
userspace.  vbus/venet leave almost nothing to userspace.

vbus redoes everything that the guest's native bus provides, virtio-pci 
relies on pci.  I haven't called it evil or heavy duty, just unnecessary.

(btw, your current alacrityvm patch is larger than kvm when it was first 
merged into Linux)

>>>
>>>        
>> Note whenever I mention migration, large guests, or Windows you say
>> these are not your design requirements.
>>      
> Actually, I don't think I've ever said that, per se.  I said that those
> things are not a priority for me, personally.  I never made a design
> decision that I knew would preclude the support for such concepts.  In
> fact, afaict, the design would support them just fine, given resources
> the develop them.
>    

So given three choices:

1. merge vbus without those things that we need
2. merge vbus and start working on them
3. not merge vbus

As choice 1 gives me nothing and choice 2 takes away development effort, 
choice 3 is the winner.

> For the record: I never once said "vbus is done".  There is plenty of
> work left to do.  This is natural (kvm I'm sure wasn't 100% when it went
> in either, nor is it today)
>    

Which is why I want to concentrate effort in one direction, not wander 
off in many.

-- 
error compiling committee.c: too many arguments to function

