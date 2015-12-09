From: "Lan, Tianyu" <tianyu.lan@intel.com>
Subject: Re: [RFC PATCH V2 0/3] IXGBE/VFIO: Add live migration
 support for SRIOV NIC
Date: Wed, 9 Dec 2015 17:28:10 +0800
Message-ID: <5667F42A.9050804@intel.com>
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
	<5661C86D.3010904@gmail.com> <5665A884.2020102@intel.com>
	<CAKgT0UeFzW_tpdSr=Ck6X6w2XnAUJquW46mo2H0Ag=Z=q0tgtg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Wei Yang <weiyang@linux.vnet.ibm.com>, "Tantilov,
	Emil S" <emil.s.tantilov@intel.com>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	"qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "Brandeburg,
	Jesse" <jesse.brandeburg@intel.com>, "Rustad,
	Mark D" <mark.d.rustad@intel.com>, "Wyborny,
	Carolyn" <carolyn.wyborny@intel.com>,
	Eric Auger <eric.auger@linaro.org>, "Skidmore,
	Donald C" <donald.c.skidmore@intel.com>,
	"zajec5@gmail.com" <zajec5@gmail.com>, Alexander Graf <agraf@suse.de>,
	intel-wired-lan <intel-wired-lan@lists.osuosl.org>, "Kirsher,
	Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	Or Gerlitz <gerlitz.or@gmail.com>, "Williams,
	Mitch A" <mitch.a.williams@intel.com>, "Jani,
	Nrupal" <nrupal.jani@intel.com>, Bjorn Helgaas <bhelgaas@google.com>,
	"a.motakis@virtualopensystems.com" <a.motakis@virtualopensystems.com>,
	"b.reynal@virtualopen
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org>
In-Reply-To: <CAKgT0UeFzW_tpdSr=Ck6X6w2XnAUJquW46mo2H0Ag=Z=q0tgtg@mail.gmail.com>
List-Unsubscribe: <https://lists.nongnu.org/mailman/options/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=unsubscribe>
List-Archive: <http://lists.nongnu.org/archive/html/qemu-devel>
List-Post: <mailto:qemu-devel@nongnu.org>
List-Help: <mailto:qemu-devel-request@nongnu.org?subject=help>
List-Subscribe: <https://lists.nongnu.org/mailman/listinfo/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=subscribe>
Errors-To: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
Sender: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
List-Id: netdev.vger.kernel.org



On 12/8/2015 1:12 AM, Alexander Duyck wrote:
> On Mon, Dec 7, 2015 at 7:40 AM, Lan, Tianyu <tianyu.lan@intel.com> wrote:
>> On 12/5/2015 1:07 AM, Alexander Duyck wrote:
>>>>
>>>>
>>>> We still need to support Windows guest for migration and this is why our
>>>> patches keep all changes in the driver since it's impossible to change
>>>> Windows kernel.
>>>
>>>
>>> That is a poor argument.  I highly doubt Microsoft is interested in
>>> having to modify all of the drivers that will support direct assignment
>>> in order to support migration.  They would likely request something
>>> similar to what I have in that they will want a way to do DMA tracking
>>> with minimal modification required to the drivers.
>>
>>
>> This totally depends on the NIC or other devices' vendors and they
>> should make decision to support migration or not. If yes, they would
>> modify driver.
>
> Having to modify every driver that wants to support live migration is
> a bit much.  In addition I don't see this being limited only to NIC
> devices.  You can direct assign a number of different devices, your
> solution cannot be specific to NICs.

We are also adding such migration support for QAT device and so our
solution will not just be limit to NIC. Now just is the beginning.

We can't limit user to only use Linux guest. So the migration feature
should work for both Windows and Linux guest.

>
>> If just target to call suspend/resume during migration, the feature will
>> be meaningless. Most cases don't want to affect user during migration
>> a lot and so the service down time is vital. Our target is to apply
>> SRIOV NIC passthough to cloud service and NFV(network functions
>> virtualization) projects which are sensitive to network performance
>> and stability. From my opinion, We should give a change for device
>> driver to implement itself migration job. Call suspend and resume
>> callback in the driver if it doesn't care the performance during migration.
>
> The suspend/resume callback should be efficient in terms of time.
> After all we don't want the system to stall for a long period of time
> when it should be either running or asleep.  Having it burn cycles in
> a power state limbo doesn't do anyone any good.  If nothing else maybe
> it will help to push the vendors to speed up those functions which
> then benefit migration and the system sleep states.

If we can benefit both migration and suspend, that would be wonderful.
But migration and system pm is still different. Just for example,
driver doesn't need to put device into deep D-status during migration
and host can do this after migration while it's essential for
system sleep. PCI configure space and interrupt config is emulated by
Qemu and Qemu can migrate these configures to new machine. Driver
doesn't need to deal with such thing. So I think migration still needs a
different callback or different code path than device suspend/resume.

Another concern is that we have to rework PM core ore PCI bus driver
to call suspend/resume for passthrough devices during migration. This
also blocks new feature works on the Windows.

>
> Also you keep assuming you can keep the device running while you do
> the migration and you can't.  You are going to corrupt the memory if
> you do, and you have yet to provide any means to explain how you are
> going to solve that.


The main problem is tracking DMA issue. I will repose my solution in the
new thread for discussion. If not way to mark DMA page dirty when
DMA is enabled, we have to stop DMA for a small time to do that at the
last stage.

>
>>
>>>
>>>> Following is my idea to do DMA tracking.
>>>>
>>>> Inject event to VF driver after memory iterate stage
>>>> and before stop VCPU and then VF driver marks dirty all
>>>> using DMA memory. The new allocated pages also need to
>>>> be marked dirty before stopping VCPU. All dirty memory
>>>> in this time slot will be migrated until stop-and-copy
>>>> stage. We also need to make sure to disable VF via clearing the
>>>> bus master enable bit for VF before migrating these memory.
>>>
>>>
>>> The ordering of your explanation here doesn't quite work.  What needs to
>>> happen is that you have to disable DMA and then mark the pages as dirty.
>>>    What the disabling of the BME does is signal to the hypervisor that
>>> the device is now stopped.  The ixgbevf_suspend call already supported
>>> by the driver is almost exactly what is needed to take care of something
>>> like this.
>>
>>
>> This is why I hope to reserve a piece of space in the dma page to do dummy
>> write. This can help to mark page dirty while not require to stop DMA and
>> not race with DMA data.
>
> You can't and it will still race.  What concerns me is that your
> patches and the document you referenced earlier show a considerable
> lack of understanding about how DMA and device drivers work.  There is
> a reason why device drivers have so many memory barriers and the like
> in them.  The fact is when you have CPU and a device both accessing
> memory things have to be done in a very specific order and you cannot
> violate that.
>
> If you have a contiguous block of memory you expect the device to
> write into you cannot just poke a hole in it.  Such a situation is not
> supported by any hardware that I am aware of.
>
> As far as writing to dirty the pages it only works so long as you halt
> the DMA and then mark the pages dirty.  It has to be in that order.
> Any other order will result in data corruption and I am sure the NFV
> customers definitely don't want that.
>
>> If can't do that, we have to stop DMA in a short time to mark all dma
>> pages dirty and then reenable it. I am not sure how much we can get by
>> this way to track all DMA memory with device running during migration. I
>> need to do some tests and compare results with stop DMA diretly at last
>> stage during migration.
>
> We have to halt the DMA before we can complete the migration.  So
> please feel free to test this.

If we can inject interrupt to notify driver just before stopping VCPU
and then stop DMA, it will not affect service down time a lot since the
network still will be down when stop VCPU.

So the question will be converted to how and when notify device driver 
about migration status.

>
> In addition I still feel you would be better off taking this in
> smaller steps.  I still say your first step would be to come up with a
> generic solution for the dirty page tracking like the dma_mark_clean()
> approach I had mentioned earlier.  If I get time I might try to take
> care of it myself later this week since you don't seem to agree with
> that approach.

No, doing dummy write in the generic function is a good idea. This
will benefit for all passthough devices. Dummy write is essential
regardless of stopping DMA or not during migration unless hardware
supports the DMA tracking.

>
>>>
>>> The question is how we would go about triggering it.  I really don't
>>> think the PCI configuration space approach is the right idea.
>>>   I wonder
>>> if we couldn't get away with some sort of ACPI event instead.  We
>>> already require ACPI support in order to shut down the system
>>> gracefully, I wonder if we couldn't get away with something similar in
>>> order to suspend/resume the direct assigned devices gracefully.
>>>
>>
>> I don't think there is such events in the current spec.
>> Otherwise, There are two kinds of suspend/resume callbacks.
>> 1) System suspend/resume called during S2RAM and S2DISK.
>> 2) Runtime suspend/resume called by pm core when device is idle.
>> If you want to do what you mentioned, you have to change PM core and
>> ACPI spec.
>
> The thought I had was to somehow try to move the direct assigned
> devices into their own power domain and then simulate a AC power event
> where that domain is switched off.  However I don't know if there are
> ACPI events to support that since the power domain code currently only
> appears to be in use for runtime power management.

This is my concern that how to suspend the passthough device. PM
callback only works during system pm(S3, S4) and runtime pm. You
have to add some codes in the PM core and PCI bus driver to do something
like force suspend when get migration event.

So far, I know GFX device will register callback on the AC power event 
and change backlight when AC is plugged or unplugged.

>
> That had also given me the thought to look at something like runtime
> power management for the VFs.  We would need to do a runtime
> suspend/resume.  The only problem is I don't know if there is any way
> to get the VFs to do a quick wakeup.  It might be worthwhile looking
> at trying to check with the ACPI experts out there to see if there is
> anything we can do as bypassing having to use the configuration space
> mechanism to signal this would definitely be worth it.
>

Currently the PCI configuration space is to share migration status and 
device information. Notify is done by injecting device irq. If we can't 
safely find free PCI configure space, need to find other place to store 
these info.

If you just need to wake up a PCI device, PME maybe help.
