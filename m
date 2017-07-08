Return-Path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0099.outbound.protection.outlook.com ([104.47.40.99]:45074
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751210AbdGHAaO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 7 Jul 2017 20:30:14 -0400
From: Casey Leedom <leedom@chelsio.com>
To: Ding Tianhong <dingtianhong@huawei.com>,
        "ashok.raj@intel.com" <ashok.raj@intel.com>,
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
        "jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>,
        "catalin.marinas@arm.com" <catalin.marinas@arm.com>,
        "will.deacon@arm.com" <will.deacon@arm.com>,
        "mark.rutland@arm.com" <mark.rutland@arm.com>,
        "robin.murphy@arm.com" <robin.murphy@arm.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "alexander.duyck@gmail.com" <alexander.duyck@gmail.com>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH v6 0/3] Add new PCI_DEV_FLAGS_NO_RELAXED_ORDERING flag
Date: Sat, 8 Jul 2017 00:30:12 +0000
Message-ID: <MWHPR12MB160006024D920ED58126048AC8AB0@MWHPR12MB1600.namprd12.prod.outlook.com>
References: <1498133721-21152-1-git-send-email-dingtianhong@huawei.com>,<MWHPR12MB160087E9E0B17F7A17609714C8AA0@MWHPR12MB1600.namprd12.prod.outlook.com>
In-Reply-To: <MWHPR12MB160087E9E0B17F7A17609714C8AA0@MWHPR12MB1600.namprd12.prod.outlook.com>
Content-Language: en-US
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  By the way, it ~seems~ like the patch set confuses the idea of the PCIe C=
apability Device Control[Relaxed Ordering Enable] with the device's ability=
 to handle incoming TLPs with the Relaxed Ordering Attribute set.  These ar=
e completely different things.  The PCIe Capability Device Control[Relaxed =
Ordering Enable] solely governs the ability of the device to _send_ TLPs wi=
th the Relaxed Ordering Attribute set.  It has nothing whatsoever to do wit=
h the handling of incoming TLPs with the Relaxed Ordering Attribute set.  I=
n fact, there is any standard way to disable receipt processing of such TLP=
s.  That's kind of the whole point of the majority of the patch.  If there =
was a separate "Ignore Incoming Relaxed Ordering Attributes" then we'd most=
ly just have a quirk which would set that for problematic devices.

  Worse yet, if I'm reading the patch right, it _is_ turning off the PCIe C=
apability Device Control[Relaxed Ordering Enable] for the devices that we'v=
e identified with problematic receive handling.  Not only does this not sol=
ve the problem that we've been talking about, it actually almost certainly =
introduces a huge Graphics Performance Bug.  The Relaxed Ordering Attribute=
 was originally developed for Graphics Device support in order to download =
textures, etc. to a graphics devices as fast as possible and only ensure or=
dering at points where needed.  For instance, as far as I know, the Intel R=
oot Complexes that we've been talking about have no issues whatsoever in ge=
nerating downstream TLPs with the Relaxed Ordering Attribute set.  By turni=
ng off the PCIe Capability Device Control[Relaxed Ordering Enable] on these=
 Root Complexes, this patch prevents the generation of downstream TLPs with=
 the Relaxed Ordering Attribute set targeted at devices like graphics adapt=
ers.

Casey=
