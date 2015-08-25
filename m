From: kbuild test robot <fengguang.wu@intel.com>
Subject: [net-next:master 1267/1290] net/rds/ib_recv.c:382:28: sparse:
 incorrect type in initializer (different base types)
Date: Wed, 26 Aug 2015 06:42:39 +0800
Message-ID: <201508260636.uzScUNFH%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org,
	Ajaykumar Hotchandani <ajaykumar.hotchandani@oracle.com>,
	Santosh Shilimkar <ssantosh@kernel.org>, netdev@vger.kernel.org
To: "santosh.shilimkar@oracle.com" <santosh.shilimkar@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:62356 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751798AbbHYWjg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Aug 2015 18:39:36 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
head:   04e1b7341dc33abe4dd3f761e2e9137701e55684
commit: 73ce4317bf983282593aff710b112a7e705620c3 [1267/1290] RDS: make sure we post recv buffers
reproduce:
  # apt-get install sparse
  git checkout 73ce4317bf983282593aff710b112a7e705620c3
  make ARCH=x86_64 allmodconfig
  make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

>> net/rds/ib_recv.c:382:28: sparse: incorrect type in initializer (different base types)
   net/rds/ib_recv.c:382:28:    expected int [signed] can_wait
   net/rds/ib_recv.c:382:28:    got restricted gfp_t
   net/rds/ib_recv.c:828:23: sparse: cast to restricted __le64

vim +382 net/rds/ib_recv.c

   366	}
   367	
   368	/*
   369	 * This tries to allocate and post unused work requests after making sure that
   370	 * they have all the allocations they need to queue received fragments into
   371	 * sockets.
   372	 *
   373	 * -1 is returned if posting fails due to temporary resource exhaustion.
   374	 */
   375	void rds_ib_recv_refill(struct rds_connection *conn, int prefill, gfp_t gfp)
   376	{
   377		struct rds_ib_connection *ic = conn->c_transport_data;
   378		struct rds_ib_recv_work *recv;
   379		struct ib_recv_wr *failed_wr;
   380		unsigned int posted = 0;
   381		int ret = 0;
 > 382		int can_wait = gfp & __GFP_WAIT;
   383		u32 pos;
   384	
   385		/* the goal here is to just make sure that someone, somewhere
   386		 * is posting buffers.  If we can't get the refill lock,
   387		 * let them do their thing
   388		 */
   389		if (!acquire_refill(conn))
   390			return;

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
