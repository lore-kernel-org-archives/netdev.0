From: "Raj, Ashok" <ashok.raj@intel.com>
Subject: Re: [PATCH v7 2/3] PCI: Enable PCIe Relaxed Ordering if supported
Date: Thu, 3 Aug 2017 01:31:53 -0700
Message-ID: <20170803083153.GB4883@otc-nc-03>
References: <e496ff1d-b836-ebef-fdf7-76273aaaaef6@codeaurora.org>
 <0260e398-bd8e-6615-6d5c-1f7c07b6fc09@huawei.com>
 <67be791f-e0cf-8284-9229-17174dc741ef@codeaurora.org>
 <5f9b8bfb-41a8-a17c-6fea-581aec1d5573@huawei.com>
 <20170724090516.2e0f0d2a@w520.home>
 <MWHPR12MB1600065968964410EDFBDA3BC8B90@MWHPR12MB1600.namprd12.prod.outlook.com>
 <75213fca-4522-2297-3cb8-338e643d3552@huawei.com>
 <CAKgT0UcqdRCwDDxD=22Q_jLuqz8KVHwH1-V45Aq-1WzQw=agcA@mail.gmail.com>
 <14218972-553d-eb60-0207-460ac7f4b064@huawei.com>
 <MWHPR12MB1600A6986E4AD13D302F2DC9C8B00@MWHPR12MB1600.namprd12.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: Ding Tianhong <dingtianhong@huawei.com>,
        Alexander Duyck <alexander.duyck@gmail.com>,
        Alex Williamson <alex.williamson@redhat.com>,
        Sinan Kaya <okaya@codeaurora.org>,
        "bhelgaas@google.com" <bhelgaas@google.com>,
        "helgaas@kernel.org" <helgaas@kernel.org>,
        Michael Werner <werner@chelsio.com>,
        Ganesh GR <ganeshgr@chelsio.com>,
        "asit.k.mallick@intel.com" <asit.k.mallick@intel.com>,
        "patrick.j.cramer@intel.com" <patrick.j.cramer@intel.com>,
        "Suravee.Suthikulpanit@amd.com" <Suravee.Suthikulpanit@amd.com>,
        "Bob.Shaw@amd.com" <Bob.Shaw@amd.com>,
        "l.stach@pengutronix.de" <l.stach@pengutronix.de>,
        "amira@mellanox.com" <amira@mellanox.com>,
        "gabriele.paoloni@huawei.com" <gabriele.paoloni@huawei.com>,
        "David.Laight@aculab.com" <David.Laight@aculab.com>,
        "jeffrey.t.kirsh
To: Casey Leedom <leedom@chelsio.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <MWHPR12MB1600A6986E4AD13D302F2DC9C8B00@MWHPR12MB1600.namprd12.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Casey

On Wed, Aug 02, 2017 at 05:53:52PM +0000, Casey Leedom wrote:
>   Okay, here you go.  As you can tell, it's almost a trivial copy of the
> cxgb4 patch.
>  
>   By the way, I realized that we have yet another hole which is likely not
> to be fixable.  If we're dealing with a problematic Root Complex, and we
> instantiate Virtual Functions and attach them to a Virtual Machine along
> with an NVMe device which can deal with Relaxed Ordering TLPs, the VF driver
> in the VM will be able to tell that it shouldn't attempt to send RO TLPs to
> the RC because it will see the state of its own PCIe Capability Device
> Control[Relaxed Ordering Enable] (a copy of the setting in the VF's
> corresponding PF), but it won't be able to change that and send non-RO TLPs
> to the RC, and RO TLPs to the NVMe device.  Oh well.

I don't understand this completely.. So your driver would know not to send RO
TLP's to root complex. But you want to send RO to the NVMe device? This is the
peer-2-peer case correct?

The issue in the current patchset is that we device to turn off the device 
capability for all devices in the hierarchy so one would expect that 
the NVMe also would have RO turned off i suppose. 

The other approach is to not turn off the device capabilty, but let the
driver do the right thing. i.e for transactions towards system memory vs. 
peer-2-peer? But since we wanted to take a big hammer approach because
some platforms there can be data-corruption and we can't let trust guest
drivers to do the right thing. This isn't something we can fix in this 
current version.

One possible approach is to provide a strict flag, where we use this heavy 
hammer approach only on platforms that have a serious implication, and the 
other is we let the driver do the right thing depending on the platform.

Worst case if the driver doesn't do the right thing, you would see perf issues
but nothing bad would happen. It would allow you to select when to turn on 
RO and when to turn it off.

Cheers,
Ashok
