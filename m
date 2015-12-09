From: "Lan, Tianyu" <tianyu.lan-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC PATCH V2 0/3] IXGBE/VFIO: Add live migration support for
 SRIOV NIC
Date: Wed, 9 Dec 2015 19:19:15 +0800
Message-ID: <56680E33.6040204@intel.com>
References: <CAKgT0Ucyq=7OSYBVvU9Z01b3f6scS+eBMLg+yphW7bwkNZosPQ@mail.gmail.com>
 <565BF285.4040507@intel.com>
 <CAKgT0Uc+-gFAetEfde6DmMOFK+vDE6UkgsNF8oLNqaQc4USSeg@mail.gmail.com>
 <565DB6FF.1050602@intel.com> <20151201171140-mutt-send-email-mst@redhat.com>
 <CAKgT0UfLEJpV-KdqRGfzBeas8bdqfHCmT5Xc8iVVP03g_pQO8A@mail.gmail.com>
 <20151201193026-mutt-send-email-mst@redhat.com>
 <CAKgT0UfJ7w6yYcZcF2YZyDKEwvE7Gh3P-jfGQGKLfPH2crVBzw@mail.gmail.com>
 <20151202105955-mutt-send-email-mst@redhat.com> <5661C000.8070201@intel.com>
 <20151209122831-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.duyck-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
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
	"
To: "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20151209122831-mutt-send-email-mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 12/9/2015 6:37 PM, Michael S. Tsirkin wrote:
> On Sat, Dec 05, 2015 at 12:32:00AM +0800, Lan, Tianyu wrote:
>> Hi Michael & Alexander:
>> Thanks a lot for your comments and suggestions.
>
> It's nice that it's appreciated, but you then go on and ignore
> all that I have written here:
> https://www.mail-archive.com/kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org/msg123826.html
>

No, I will reply it separately and according your suggestion to snip it 
into 3 thread.

>> We still need to support Windows guest for migration and this is why our
>> patches keep all changes in the driver since it's impossible to change
>> Windows kernel.
>
> This is not a reasonable argument.  It makes no sense to duplicate code
> on Linux because you must duplicate code on Windows.  Let's assume you
> must do it in the driver on windows because windows has closed source
> drivers.  What does it matter? Linux can still do it as part of DMA API
> and have it apply to all drivers.
>

Sure. Duplicated code should be encapsulated and make it able to reuse
by other drivers. Just like you said the dummy write part.

I meant the framework should not require to change Windows kernel code
(such as PM core or PCI bus driver)and this will block implementation on
the Windows.

I think it's not problem to duplicate code in the Windows drivers.

>> Following is my idea to do DMA tracking.
>>
>> Inject event to VF driver after memory iterate stage
>> and before stop VCPU and then VF driver marks dirty all
>> using DMA memory. The new allocated pages also need to
>> be marked dirty before stopping VCPU. All dirty memory
>> in this time slot will be migrated until stop-and-copy
>> stage. We also need to make sure to disable VF via clearing the
>> bus master enable bit for VF before migrating these memory.
>>
>> The dma page allocated by VF driver also needs to reserve space
>> to do dummy write.
>
> I suggested ways to do it all in the hypervisor without driver hacks, or
> hide it within DMA API without need to reserve extra space. Both
> approaches seem much cleaner.
>

This sounds reasonable. We may discuss it detail in the separate thread.
