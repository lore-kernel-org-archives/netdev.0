From: "Liran Liss" <liranl@mellanox.co.il>
Subject: RE: [PATCH 16/25] mlx4_core: boot sriov
Date: Thu, 5 Nov 2009 18:21:29 +0200
Message-ID: <2ED289D4E09FBD4D92D911E869B97FDD0166CD80@mtlexch01.mtl.com>
References: <4AF19E5D.1060806@mellanox.co.il> <aday6mmyshm.fsf@cisco.com><2ED289D4E09FBD4D92D911E869B97FDD0166CA13@mtlexch01.mtl.com> <adafx8tc6cu.fsf@roland-alpha.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: "Yevgeny Petrilin" <yevgenyp@mellanox.co.il>,
	<linux-rdma@vger.kernel.org>, <netdev@vger.kernel.org>,
	"Tziporet Koren" <tziporet@mellanox.co.il>
To: "Roland Dreier" <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:53720 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756623AbZKEQTP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2009 11:19:15 -0500
Content-class: urn:content-classes:message
In-reply-to: <adafx8tc6cu.fsf@roland-alpha.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I was also thinking about backports to older kernels without sriov at
all, which will probably be in our VMs in the near future.
For these kernels, we still want to the code to operate in slave mode...

Anyway, we can push the pci_enable_sriov() stub to the OFED backport
system as well, so I am fine.
10x,
--Liran


-----Original Message-----
From: Roland Dreier [mailto:rdreier@cisco.com] 
Sent: Thursday, November 05, 2009 5:57 PM
To: Liran Liss
Cc: Yevgeny Petrilin; linux-rdma@vger.kernel.org;
netdev@vger.kernel.org; Tziporet Koren
Subject: Re: [PATCH 16/25] mlx4_core: boot sriov


 > LL: I think that this won't pass -Wall when compiling against a
kernel  > with sriov compiled out.

Why not?  The sriov code provides stubs like:

static inline int pci_enable_sriov(struct pci_dev *dev, int nr_virtfn) {
	return -ENODEV;
}

if CONFIG_PCI_IOV is not enabled.

 - R.
