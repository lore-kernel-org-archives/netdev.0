From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Subject: Re: [RFC PATCH 2/2] igb/ixgbe: add code to trigger function reset
 if reset_devices is set
Date: Tue, 10 Aug 2010 18:31:47 +0900
Message-ID: <4C611C83.6080301@jp.fujitsu.com>
References: <20100731005803.32625.6891.stgit@localhost.localdomain>	 <20100731005910.32625.89518.stgit@localhost.localdomain>	 <20100801.011516.191407437.davem@davemloft.net> <1281025664.8720.28.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, jeffrey.t.kirsher@intel.com,
	jbarnes@virtuousgeek.org, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org, alexander.h.duyck@intel.com
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <1281025664.8720.28.camel@localhost>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(2010/08/06 1:27), David Woodhouse wrote:
> On Sun, 2010-08-01 at 01:15 -0700, David Miller wrote:
>> From: Jeff Kirsher<jeffrey.t.kirsher@intel.com>
>> Date: Fri, 30 Jul 2010 17:59:12 -0700
>>
>>> From: Alexander Duyck<alexander.h.duyck@intel.com>
>>>
>>> This change makes it so that both igb and ixgbe can trigger a full pcie
>>> function reset if the reset_devices kernel parameter is defined.  The main
>>> reason for adding this is that kdump can cause serious issues when the
>>> kdump kernel resets the IOMMU while DMA transactions are still occurring.
>>>
>>> Signed-off-by: Alexander Duyck<alexander.h.duyck@intel.com>
>>> Signed-off-by: Jeff Kirsher<jeffrey.t.kirsher@intel.com>
>>
>> I tend to disagree with the essence of this change.
>>
>> Which is that we should add workaround after workaround for things
>> that aren't functioning properly in kdump and kexec.
>>
>> They should have a pass that shuts devices down properly, so that this
>> kind of stuff doesn't need to happen in the kernel we then boot into.
>
> For a normal kexec, arguably true.
>
> But in the kdump case, the original kernel has *crashed* and we really
> don't have that option -- we need to jump *straight* to the new kernel
> and have it reset the hardware.
>
> The device driver really *ought* to be able to reset the hardware from
> whatever state it's in when the new kernel starts up. Anything less is
> broken, and reminds me of those crappy drivers that only work after a
> soft-reboot from Windows.
>
> Most drivers *do* quite happily initialise their device and reliably get
> it into a known state; it's just that this particular hardware goes into
> a *particularly* stroppy fit when it gets a DMA master abort (which is
> what happens when the IOMMU stops it from scribbling into memory after
> the new kernel has taken over).
>
>> What happens on non-PCIE systems then?  Do they just lose when this
>> happens?
>
> If they have a device that's this broken, and the driver can't get it
> into a working state any other way, then yes -- I don't see any way to
> *avoid* them losing.

What about asserting secondary RST# on the bridge?
It would not work for devices on the root bus though.

Thanks,
Kenji Kaneshige
