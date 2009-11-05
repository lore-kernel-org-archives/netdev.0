From: "Liran Liss" <liranl@mellanox.co.il>
Subject: RE: [PATCH 16/25] mlx4_core: boot sriov
Date: Thu, 5 Nov 2009 15:26:17 +0200
Message-ID: <2ED289D4E09FBD4D92D911E869B97FDD0166CA13@mtlexch01.mtl.com>
References: <4AF19E5D.1060806@mellanox.co.il> <aday6mmyshm.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: <linux-rdma@vger.kernel.org>, <netdev@vger.kernel.org>,
	"Tziporet Koren" <tziporet@mellanox.co.il>
To: "Roland Dreier" <rdreier@cisco.com>,
	"Yevgeny Petrilin" <yevgenyp@mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:45447 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756175AbZKENYD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2009 08:24:03 -0500
Content-class: urn:content-classes:message
In-reply-to: <aday6mmyshm.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 S.B.
--Liran

-----Original Message-----
From: Roland Dreier [mailto:rdreier@cisco.com] 
Sent: Wednesday, November 04, 2009 9:56 PM
To: Yevgeny Petrilin
Cc: linux-rdma@vger.kernel.org; netdev@vger.kernel.org; Liran Liss;
Tziporet Koren
Subject: Re: [PATCH 16/25] mlx4_core: boot sriov


 > +	/* Detect if this device is a virtual function */
 > +	switch (id->device) {
 > +	case 0x6341:
 > +	case 0x634b:
 > +	case 0x6733:
 > +	case 0x673d:
 > +	case 0x6369:
 > +	case 0x6751:
 > +	case 0x6765:

This isn't be maintainable or sane.  How about using driver_data in the
PCI device table?
LL: good idea; 10x.

 > +#ifdef CONFIG_PCI_IOV
 > +		if (sr_iov) {

Can we avoid a lot of these ifdefs by just doing

#else
#define sr_iov	0
#endif /* CONFIG_PCI_IOV */

at the beginning and letting the IOV code be optimized away?

LL: I think that this won't pass -Wall when compiling against a kernel
with sriov compiled out.

 - R.
