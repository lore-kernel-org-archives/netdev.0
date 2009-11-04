From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH 16/25] mlx4_core: boot sriov
Date: Wed, 04 Nov 2009 11:55:49 -0800
Message-ID: <aday6mmyshm.fsf@cisco.com>
References: <4AF19E5D.1060806@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
	liranl@mellanox.co.il, tziporet@mellanox.co.il
To: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:5819 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755413AbZKDTzp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 14:55:45 -0500
In-Reply-To: <4AF19E5D.1060806@mellanox.co.il> (Yevgeny Petrilin's message of
	"Wed, 04 Nov 2009 17:31:41 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


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

 > +#ifdef CONFIG_PCI_IOV
 > +		if (sr_iov) {

Can we avoid a lot of these ifdefs by just doing

#else
#define sr_iov	0
#endif /* CONFIG_PCI_IOV */

at the beginning and letting the IOV code be optimized away?

 - R.
