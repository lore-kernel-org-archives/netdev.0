From: Yinghai Lu <yinghai@kernel.org>
Subject: Re: [PATCH 6/7] PCI: Make sure VF's driver get attached after PF's
Date: Tue, 14 May 2013 12:59:33 -0700
Message-ID: <CAE9FiQVGGHB_amKw0-DfDifpTnRGPbxA+q3WY5F-O3x-sx386A@mail.gmail.com>
References: <1368498506-25857-1-git-send-email-yinghai@kernel.org>
	<1368498506-25857-7-git-send-email-yinghai@kernel.org>
	<51925FB0.4080504@intel.com>
	<CAE9FiQXYQEAZ=0sG6+2OdffBqfLS9MpoN1xviRR9aDbxPxcKxQ@mail.gmail.com>
	<5192946F.1050700@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Bjorn Helgaas <bhelgaas@google.com>,
	Gu Zheng <guz.fnst@cn.fujitsu.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <5192946F.1050700@intel.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 14, 2013 at 12:45 PM, Alexander Duyck
<alexander.h.duyck@intel.com> wrote:
> On 05/14/2013 11:44 AM, Yinghai Lu wrote:
>> On Tue, May 14, 2013 at 9:00 AM, Alexander Duyck
>> <alexander.h.duyck@intel.com> wrote:

>>> I'm sorry, but what is the point of this patch?  With device assignment
>>> it is always possible to have VFs loaded and the PF driver unloaded
>>> since you cannot remove the VFs if they are assigned to a VM.
>> unload PF driver will not call pci_disable_sriov?
>
> You cannot call pci_disable_sriov because you will panic all of the
> guests that have devices assigned.

ixgbe_remove did call pci_disable_sriov...

for guest panic, that is another problem.
just like you pci passthrough with real pci device and hotremove the
card in host.

...

> So how does your patch actually fix this problem?  It seems like it is
> just avoiding it.

yes, until the first one is done.

>
> From what I can tell your problem is originating in pci_call_probe.  I
> believe it is calling work_on_cpu and that doesn't seem correct since
> the work should be taking place on a CPU already local to the PF. You
> might want to look there to see why you are trying to schedule work on a
> CPU which should be perfectly fine for you to already be doing your work on.

it always try to go with local cpu with same pxm.
