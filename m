From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: Re: [Intel-wired-lan] [PATCH] pci: Limit VPD reads for all Intel
 Ethernet devices
Date: Tue, 19 May 2015 13:39:16 -0700
Message-ID: <555B9F74.3040004@redhat.com>
References: <20150519000042.56109.69779.stgit@mdrustad-wks.jf.intel.com> <555B5CBF.1090902@redhat.com> <4AD84211-965C-4F0B-A7F4-3E6CCE6567E3@intel.com> <555B77E5.5060006@redhat.com> <99014381-25AB-416D-8E09-C431B5CD5A6C@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "bhelgaas@google.com" <bhelgaas@google.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Rustad, Mark D" <mark.d.rustad@intel.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <99014381-25AB-416D-8E09-C431B5CD5A6C@intel.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 05/19/2015 11:38 AM, Rustad, Mark D wrote:
>> On May 19, 2015, at 10:50 AM, Alexander Duyck <alexander.h.duyck@redhat.com> wrote:
>>
>> These two patches are very much related.
> They are only related because I saw an opportunity to do this while working on the other issue. That is the only relationship.
>
> <snip material on the other patch>
>
>>>> Artificially limiting the size of the VPD does nothing but cut off possibly useful data, you would be better of providing all of the data on only the first function than providing only partial data on all functions and adding extra lock overhead.
>>> This limit only limits the maximum that the OS will read to what is architecturally possible in these devices. Yes, PCIe architecturally provides for the possibility of more, but these devices do not. More repeating data can be read, however slowly, but there is no possibility of useful content beyond the first 1K. If this limit were set to 0x100, which is more in line what the actual usage is, it would be an artificial limit, but at 1K it is not. Oh and it does include devices made by others that incorporate Intel Ethernet silicon, not just Intel-built devices.
>> As per section 3.4.4 of the X540 datasheet the upper addressable range for the VPD section is 0xFFF which means the upper limit for the hardware is 0x1000, not 0x400.
> Ok. I have no problem changing it to that. I had been looking at other specs, but 0x1000 really is a hard limit.
>
> <snip more material mostly relating to the other patch>

So how does this improve boot time anyway?  The original patch 
description said this improved boot time and reduced memory usage but I 
have yet to find where any of those gains would actually occur.  If you 
can point me in that direction I might have a better idea of the 
motivations behind this.

- Alex
