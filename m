From: "Raj, Ashok" <ashok.raj@intel.com>
Subject: Re: [PATCH v7 2/3] PCI: Enable PCIe Relaxed Ordering if supported
Date: Fri, 4 Aug 2017 13:21:41 -0700
Message-ID: <20170804202141.GA39054@otc-nc-03>
References: <67be791f-e0cf-8284-9229-17174dc741ef@codeaurora.org>
 <5f9b8bfb-41a8-a17c-6fea-581aec1d5573@huawei.com>
 <20170724090516.2e0f0d2a@w520.home>
 <MWHPR12MB1600065968964410EDFBDA3BC8B90@MWHPR12MB1600.namprd12.prod.outlook.com>
 <75213fca-4522-2297-3cb8-338e643d3552@huawei.com>
 <CAKgT0UcqdRCwDDxD=22Q_jLuqz8KVHwH1-V45Aq-1WzQw=agcA@mail.gmail.com>
 <14218972-553d-eb60-0207-460ac7f4b064@huawei.com>
 <MWHPR12MB1600A6986E4AD13D302F2DC9C8B00@MWHPR12MB1600.namprd12.prod.outlook.com>
 <20170803083153.GB4883@otc-nc-03>
 <MWHPR12MB1600400EC7DEE92E4A3ADC5BC8B60@MWHPR12MB1600.namprd12.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
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
In-Reply-To: <MWHPR12MB1600400EC7DEE92E4A3ADC5BC8B60@MWHPR12MB1600.namprd12.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 04, 2017 at 08:20:37PM +0000, Casey Leedom wrote:
> | From: Raj, Ashok <ashok.raj@intel.com>
> | Sent: Thursday, August 3, 2017 1:31 AM
> |
> | I don't understand this completely.. So your driver would know not to send
> | RO TLP's to root complex. But you want to send RO to the NVMe device? This
> | is the peer-2-peer case correct?
> 
> Yes, this is the "heavy hammer" issue which you alluded to later.  There are
> applications where a device will want to send TLPs to a Root Complex without
> Relaxed Ordering set, but will want to use it when sending TLPs to a Peer
> device (say, an NVMe storage device).  The current approach doesn't make
> that easy ... and in fact, I still don't kow how to code a solution for this
> with the proposed APIs.  This means that we may be trading off one
> performance problem for another and that Relaxed Ordering may be doomed for
> use under Linux for the foreseeable future.
> 
> As I've noted a number of times, it would be great if the Intel Hardware
> Engineers who attempted to implement the Relaxed Ordering semantics in the
> current generation of Root Complexes had left the ability to turn off the
> logic which is obviously not working.  If there was a way to disable the
> logic via an undocumented register, then we could have the Linux PCI Quirk
> do that.  Since Relaxed Ordering is just a hint, it's completely legitimate
> to completely ignore it.

Suppose you are looking for the existence of a chicken bit to instruct the
port to ignore RO traffic. So all we would do is turn the chicken bit on
but would permit p2p traffic to be allowed since we won't turn off the
capability as currently proposed.

Let me look into that keep you posted.

Cheers,
Ashok
> 
> Casey
