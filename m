From: "Sean Hefty" <sean.hefty@intel.com>
Subject: RE: [ofa-general] [PATCH v3] iw_cxgb3: Support "iwarp-only"interfacesto avoid 4-tuple conflicts.
Date: Thu, 27 Sep 2007 12:11:49 -0700
Message-ID: <000101c8013a$41b374f0$a7cc180a@amr.corp.intel.com>
References: <20070923203649.8324.64524.stgit@dell3.ogc.int><46FBF8AF.9040700@ichips.intel.com> <C98692FD98048C41885E0B0FACD9DFB805187514@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <rdreier@cisco.com>,
	<linux-kernel@vger.kernel.org>, <general@lists.openfabrics.org>
To: "'Kanevsky, Arkady'" <Arkady.Kanevsky@netapp.com>,
	"Sean Hefty" <mshefty@ichips.intel.com>,
	"Steve Wise" <swise@opengridcomputing.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:41571 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756578AbXI0TLv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Sep 2007 15:11:51 -0400
In-Reply-To: <C98692FD98048C41885E0B0FACD9DFB805187514@exnane01.hq.netapp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>What is the model on how client connects, say for iSCSI,
>when client and server both support, iWARP and 10GbE or 1GbE,
>and would like to setup "most" performant "connection" for ULP?

For the "most" performance connection, the ULP would use IB, and all these
problems go away.  :)

This proposal is for each iwarp interface to have its own IP address.  Clients
would need an iwarp usable address of the server and would connect using
rdma_connect().  If that call (or rdma_resolve_addr/route) fails, the client
could try connecting using sockets, aoi, or some other interface.  I don't see
that Steve's proposal changes anything from the client's perspective.

- Sean
