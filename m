From: "Hefty, Sean" <sean.hefty@intel.com>
Subject: RE: [RFC 2/3] RDMA/cma: Add support for netlink statistics export
Date: Thu, 19 May 2011 18:35:39 +0000
Message-ID: <1828884A29C6694DAF28B7E6B8A82373FF9E@ORSMSX101.amr.corp.intel.com>
References: <1305303525-11113-1-git-send-email-roland@kernel.org>
 <1305303525-11113-3-git-send-email-roland@kernel.org>
 <1828884A29C6694DAF28B7E6B8A82373F428@ORSMSX101.amr.corp.intel.com>
 <BANLkTin1uVyrzdn_030bGmC=QHtfkvOTNA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>
To: Roland Dreier <roland@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:55466 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933813Ab1ESSfm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2011 14:35:42 -0400
In-Reply-To: <BANLkTin1uVyrzdn_030bGmC=QHtfkvOTNA@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Is there an easy way to get the qp_type from a struct rdma_cm_id?
> 
> ie what code needs to go into cma_get_id_stats() to handle this?

With the current code, you'd need to map from the port space:

static inline enum ib_qp_type cma_get_qp_type(struct rdma_cm_id *id)
{
	if (id->ps == RDMA_PS_IPOIB || id->ps == RDMA_PS_UDP)
		return IB_QPT_RC;
	else
		return IB_QPT_RC;
}

	..
	id_stats->qp_type = cma_get_qp_type(id);
	..

One of the patches in the af_ib patch set adds the qp_type to struct rdma_cm_id.  I'm guessing that patch will also be needed for xrc.

- Sean
