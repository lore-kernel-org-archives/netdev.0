From: Casey Leedom <leedom@chelsio.com>
Subject: Re: [PATCH v7 2/3] PCI: Enable PCIe Relaxed Ordering if supported
Date: Fri, 4 Aug 2017 20:48:34 +0000
Message-ID: <MWHPR12MB160086C4B4FA8F3B2EC1D5F9C8B60@MWHPR12MB1600.namprd12.prod.outlook.com>
References: <67be791f-e0cf-8284-9229-17174dc741ef@codeaurora.org>
 <5f9b8bfb-41a8-a17c-6fea-581aec1d5573@huawei.com>
 <20170724090516.2e0f0d2a@w520.home>
 <MWHPR12MB1600065968964410EDFBDA3BC8B90@MWHPR12MB1600.namprd12.prod.outlook.com>
 <75213fca-4522-2297-3cb8-338e643d3552@huawei.com>
 <CAKgT0UcqdRCwDDxD=22Q_jLuqz8KVHwH1-V45Aq-1WzQw=agcA@mail.gmail.com>
 <14218972-553d-eb60-0207-460ac7f4b064@huawei.com>
 <MWHPR12MB1600A6986E4AD13D302F2DC9C8B00@MWHPR12MB1600.namprd12.prod.outlook.com>
 <20170803083153.GB4883@otc-nc-03>
 <MWHPR12MB1600400EC7DEE92E4A3ADC5BC8B60@MWHPR12MB1600.namprd12.prod.outlook.com>,<20170804202141.GA39054@otc-nc-03>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Ding Tianhong <dingtianhong@huawei.com>,
        Alexander Duyck <alexander.duyck@gmail.com>,
        Alex Williamson <alex.williamson@redhat.com>,
        Sinan Kaya <okaya@codeaurora.org>,
        "bhelgaas@google.com" <bhelgaas@google.com>,
        "helgaas@kernel.org" <helgaas@kernel.org>,
        "Michael Werner" <werner@chelsio.com>,
        Ganesh GR <ganeshgr@chelsio.com>,
        "asit.k.mallick@intel.com" <asit.k.mallick@intel.com>,
        "patrick.j.cramer@intel.com" <patrick.j.cramer@intel.com>,
        "Suravee.Suthikulpanit@amd.com" <Suravee.Suthikulpanit@amd.com>,
        "Bob.Shaw@amd.com" <Bob.Shaw@amd.com>,
        "l.stach@pengutronix.de" <l.stach@pengutronix.de>,
        "amira@mellanox.com" <amira@mellanox.com>,
        "gabriele.paoloni@huawei.com" <gabriele.paoloni@huawei.com>,
        "David.Laight@aculab.com" <David.Laight@aculab.com>,
        "jeffrey.t.kir
To: "Raj, Ashok" <ashok.raj@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170804202141.GA39054@otc-nc-03>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

| From: Raj, Ashok <ashok.raj@intel.com>
| Sent: Friday, August 4, 2017 1:21 PM
|
| On Fri, Aug 04, 2017 at 08:20:37PM +0000, Casey Leedom wrote:
| > ...
| > As I've noted a number of times, it would be great if the Intel Hardwar=
e
| > Engineers who attempted to implement the Relaxed Ordering semantics in =
the
| > current generation of Root Complexes had left the ability to turn off t=
he
| > logic which is obviously not working.  If there was a way to disable th=
e
| > logic via an undocumented register, then we could have the Linux PCI Qu=
irk
| > do that.  Since Relaxed Ordering is just a hint, it's completely legiti=
mate
| > to completely ignore it.
|
| Suppose you are looking for the existence of a chicken bit to instruct th=
e
| port to ignore RO traffic. So all we would do is turn the chicken bit on
| but would permit p2p traffic to be allowed since we won't turn off the
| capability as currently proposed.
|
| Let me look into that keep you posted.

Huh, I'd never heard it called a "chicken bit" before, but yes, that's what
I'm talking about.

Whenever our Hardware Designers implement new functionality in our hardware=
,
they almost always put in A. several "knobs" which can control fundamental
parameters of the new Hardware Feature, and B.  a mechanism of completely
disabling it if necessary.  This stems from the incredibly long Design ->
Deployment cyle for Hardware (as opposed to the edit->compile->run cycle fo=
r s!

It's obvious that handling Relaxed Ordering is a new Hardware Feature for
Intel's Root Complexes since previous versions simply ignored it (because
that's legal[1]).  If I was a Hardware Engineer tasked with implementing
Relaxed Ordering semantics for a device, I would certainly have also
implemented a switch to turn it off in case there were unintended
consequences (performance in this case).

And if there is such a mechanism to simply disable processing of Relaxed
Ordering semantics in the Root Complex, that would be a far easier "fix" fo=
r
this problem ... and leave the code in place to continue sending Relaxed
Ordering TLPs for a future Root Complex implementation which got it right .=
..

Casey

[1] One can't ~quite~ just ignore the Relaxed Ordering Attribute on an
    incoming Transaction Layer Packet Request: PCIe completion rules (see
    section 2.2.9 of the PCIe 3.0 specificatin) require that the Relaxed
    Ordering and No Snoop Attributes in a Request TLP be reflected back
    verbatim in any corresponding Response TLP.  (The rules for ID-Based
    Ordering are more complex.)
