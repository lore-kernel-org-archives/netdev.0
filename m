From: "Hefty, Sean" <sean.hefty@intel.com>
Subject: [PATCH 0/26 v3] rdma/cm: Add support for native InfiniBand
 addressing
Date: Wed, 26 Sep 2012 22:35:18 +0000
Message-ID: <1828884A29C6694DAF28B7E6B8A8237346A8EE01__15265.0532931604$1348698962$gmane$org@ORSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "linux-rdma (linux-rdma@vger.kernel.org)"
	<linux-rdma@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:60991 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752954Ab2IZWfo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Sep 2012 18:35:44 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

missed copying netdev on patch cover letter...

This patch series adds the ability to handle native Infiniband addressing
to the rdma_cm.

In addition to supporting native addresses, this support allows us to offload
name and/or address translation services to a user space daemon, providing the
user greater control over path selection.  For example, a user can specify
different paths for multiple connections to the same system, or specify a
backup path for automatic path migration capabilities.  The primary motivation
is to support large scale fabrics, with address and name services either cached
or bypassed completely (information is exchanged out of band by an MPI process
manager).

The intended usage model is for applications to call rdma_getaddrinfo.  This 
call is similar to getaddrinfo, but specific for RDMA devices.  
rdma_getaddrinfo takes as input a name, IP address, GID, or LID, and returns 
full connection information.

The patch set introduces af_ib and sockaddr_ib.  The kernel rdma_cm is updated 
accordingly, mainly to make its handling of addresses more generic.  However, 
since sockaddr_ib is larger than sockaddr_in6, the rdma_ucm requires changes to 
its user to kernel interface.  To provide backwards compatibility, the 
userspace ABI is extended to support the larger address size.

Signed-off-by: Sean Hefty <sean.hefty@intel.com>

changes from v2:
updated to later kernel
