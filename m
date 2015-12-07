From: Alexander Duyck <alexander.duyck-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC PATCH V2 0/3] IXGBE/VFIO: Add live migration support for
 SRIOV NIC
Date: Mon, 7 Dec 2015 09:12:08 -0800
Message-ID: <CAKgT0UeFzW_tpdSr=Ck6X6w2XnAUJquW46mo2H0Ag=Z=q0tgtg@mail.gmail.com>
References: <CAKgT0UevBmRLpM1PvuuVDUW79A66RcPrfO8uGiqL1RiALW7apg@mail.gmail.com>
	<A12AC9D104E08D47BAF23C492F83C53B25CDE9E3@SHSMSX104.ccr.corp.intel.com>
	<CAKgT0Ucyq=7OSYBVvU9Z01b3f6scS+eBMLg+yphW7bwkNZosPQ@mail.gmail.com>
	<565BF285.4040507@intel.com>
	<CAKgT0Uc+-gFAetEfde6DmMOFK+vDE6UkgsNF8oLNqaQc4USSeg@mail.gmail.com>
	<565DB6FF.1050602@intel.com>
	<20151201171140-mutt-send-email-mst@redhat.com>
	<CAKgT0UfLEJpV-KdqRGfzBeas8bdqfHCmT5Xc8iVVP03g_pQO8A@mail.gmail.com>
	<20151201193026-mutt-send-email-mst@redhat.com>
	<CAKgT0UfJ7w6yYcZcF2YZyDKEwvE7Gh3P-jfGQGKLfPH2crVBzw@mail.gmail.com>
	<20151202105955-mutt-send-email-mst@redhat.com>
	<5661C000.8070201@intel.com>
	<5661C86D.3010904@gmail.com>
	<5665A884.2020102@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"Dong, Eddie" <eddie.dong-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"a.motakis-lrHrjnjw1UfHK3s98zE1ajGjJy/sRE9J@public.gmane.org" <a.motakis-lrHrjnjw1UfHK3s98zE1ajGjJy/sRE9J@public.gmane.org>,
	Alex Williamson <alex.williamson-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"b.reynal-lrHrjnjw1UfHK3s98zE1ajGjJy/sRE9J@public.gmane.org" <b.reynal-lrHrjnjw1UfHK3s98zE1ajGjJy/sRE9J@public.gmane.org>,
	Bjorn Helgaas <bhelgaas-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	"Wyborny, Carolyn" <carolyn.wyborny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"Skidmore, Donald C" <donald.c.skidmore-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"Jani, Nrupal" <nrupal.jani-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Alexander Graf <agraf-l3A5Bk7waGM@public.gmane.org>,
	"kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Paolo Bonzini <pbonzini-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"qemu-devel-qX2TKyscuCcdnm+yROfE0A@public.gmane.org" <qemu-devel-qX2TKyscuCcdnm+yROfE0A@public.gmane.org>,
	"Tantilov, Emil S" <emil.s.tantilov-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Or Gerlitz <gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"Rustad, Mark D" <mark.d.rustad-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Eric Auger <eric.auger-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	intel-wired-lan <intel-wired-lan-qjLDD68F18P21nG7glBr7A@public.gmane.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"Brande
To: "Lan, Tianyu" <tianyu.lan-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <5665A884.2020102-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 7, 2015 at 7:40 AM, Lan, Tianyu <tianyu.lan-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org> wrote:
> On 12/5/2015 1:07 AM, Alexander Duyck wrote:
>>>
>>>
>>> We still need to support Windows guest for migration and this is why our
>>> patches keep all changes in the driver since it's impossible to change
>>> Windows kernel.
>>
>>
>> That is a poor argument.  I highly doubt Microsoft is interested in
>> having to modify all of the drivers that will support direct assignment
>> in order to support migration.  They would likely request something
>> similar to what I have in that they will want a way to do DMA tracking
>> with minimal modification required to the drivers.
>
>
> This totally depends on the NIC or other devices' vendors and they
> should make decision to support migration or not. If yes, they would
> modify driver.

Having to modify every driver that wants to support live migration is
a bit much.  In addition I don't see this being limited only to NIC
devices.  You can direct assign a number of different devices, your
solution cannot be specific to NICs.

> If just target to call suspend/resume during migration, the feature will
> be meaningless. Most cases don't want to affect user during migration
> a lot and so the service down time is vital. Our target is to apply
> SRIOV NIC passthough to cloud service and NFV(network functions
> virtualization) projects which are sensitive to network performance
> and stability. From my opinion, We should give a change for device
> driver to implement itself migration job. Call suspend and resume
> callback in the driver if it doesn't care the performance during migration.

The suspend/resume callback should be efficient in terms of time.
After all we don't want the system to stall for a long period of time
when it should be either running or asleep.  Having it burn cycles in
a power state limbo doesn't do anyone any good.  If nothing else maybe
it will help to push the vendors to speed up those functions which
then benefit migration and the system sleep states.

Also you keep assuming you can keep the device running while you do
the migration and you can't.  You are going to corrupt the memory if
you do, and you have yet to provide any means to explain how you are
going to solve that.


>
>>
>>> Following is my idea to do DMA tracking.
>>>
>>> Inject event to VF driver after memory iterate stage
>>> and before stop VCPU and then VF driver marks dirty all
>>> using DMA memory. The new allocated pages also need to
>>> be marked dirty before stopping VCPU. All dirty memory
>>> in this time slot will be migrated until stop-and-copy
>>> stage. We also need to make sure to disable VF via clearing the
>>> bus master enable bit for VF before migrating these memory.
>>
>>
>> The ordering of your explanation here doesn't quite work.  What needs to
>> happen is that you have to disable DMA and then mark the pages as dirty.
>>   What the disabling of the BME does is signal to the hypervisor that
>> the device is now stopped.  The ixgbevf_suspend call already supported
>> by the driver is almost exactly what is needed to take care of something
>> like this.
>
>
> This is why I hope to reserve a piece of space in the dma page to do dummy
> write. This can help to mark page dirty while not require to stop DMA and
> not race with DMA data.

You can't and it will still race.  What concerns me is that your
patches and the document you referenced earlier show a considerable
lack of understanding about how DMA and device drivers work.  There is
a reason why device drivers have so many memory barriers and the like
in them.  The fact is when you have CPU and a device both accessing
memory things have to be done in a very specific order and you cannot
violate that.

If you have a contiguous block of memory you expect the device to
write into you cannot just poke a hole in it.  Such a situation is not
supported by any hardware that I am aware of.

As far as writing to dirty the pages it only works so long as you halt
the DMA and then mark the pages dirty.  It has to be in that order.
Any other order will result in data corruption and I am sure the NFV
customers definitely don't want that.

> If can't do that, we have to stop DMA in a short time to mark all dma
> pages dirty and then reenable it. I am not sure how much we can get by
> this way to track all DMA memory with device running during migration. I
> need to do some tests and compare results with stop DMA diretly at last
> stage during migration.

We have to halt the DMA before we can complete the migration.  So
please feel free to test this.

In addition I still feel you would be better off taking this in
smaller steps.  I still say your first step would be to come up with a
generic solution for the dirty page tracking like the dma_mark_clean()
approach I had mentioned earlier.  If I get time I might try to take
care of it myself later this week since you don't seem to agree with
that approach.

>>
>> The question is how we would go about triggering it.  I really don't
>> think the PCI configuration space approach is the right idea.
>>  I wonder
>> if we couldn't get away with some sort of ACPI event instead.  We
>> already require ACPI support in order to shut down the system
>> gracefully, I wonder if we couldn't get away with something similar in
>> order to suspend/resume the direct assigned devices gracefully.
>>
>
> I don't think there is such events in the current spec.
> Otherwise, There are two kinds of suspend/resume callbacks.
> 1) System suspend/resume called during S2RAM and S2DISK.
> 2) Runtime suspend/resume called by pm core when device is idle.
> If you want to do what you mentioned, you have to change PM core and
> ACPI spec.

The thought I had was to somehow try to move the direct assigned
devices into their own power domain and then simulate a AC power event
where that domain is switched off.  However I don't know if there are
ACPI events to support that since the power domain code currently only
appears to be in use for runtime power management.

That had also given me the thought to look at something like runtime
power management for the VFs.  We would need to do a runtime
suspend/resume.  The only problem is I don't know if there is any way
to get the VFs to do a quick wakeup.  It might be worthwhile looking
at trying to check with the ACPI experts out there to see if there is
anything we can do as bypassing having to use the configuration space
mechanism to signal this would definitely be worth it.

>>> The dma page allocated by VF driver also needs to reserve space
>>> to do dummy write.
>>
>>
>> No, this will not work.  If for example you have a VF driver allocating
>> memory for a 9K receive how will that work?  It isn't as if you can poke
>> a hole in the contiguous memory.

This is the bit that makes your "poke a hole" solution not portable to
other drivers.  I don't know if you overlooked it but for many NICs
jumbo frames means using large memory allocations to receive the data.
That is the way ixgbevf was up until about a year ago so you cannot
expect all the drivers that will want migration support to allow a
space for you to write to.  In addition some storage drivers have to
map an entire page, that means there is no room for a hole there.

- Alex
