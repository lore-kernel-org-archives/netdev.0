From: Simon Derr <simon.derr@bull.net>
Subject: [PATCH 00/10] Improve 9P/RDMA
Date: Tue,  2 Jul 2013 15:11:14 +0200
Message-ID: <1372770684-25573-1-git-send-email-simon.derr@bull.net>
Cc: simon.derr@bull.net, ericvh@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:40990 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752550Ab3GBNl5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jul 2013 09:41:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This is a series of patches which aim to make 9P/RDMA better.

Eric Van Hensbergen asked that I send them to netdev to get a wider review.

They deal mainly with fcall allocation/deallocation, RQ locking,
error handling, and above all buffer management.
This has been tested intensively with the nfs-ganesha server.

Regards,

	Simon

Simon Derr (10):
  9P: Fix fcall allocation for rdma
  9P/RDMA: rdma_request() needs not allocate req->rc
  9pnet: refactor struct p9_fcall alloc code
  9P/RDMA: increase P9_RDMA_MAXSIZE to 1MB
  9P/RDMA: Protect against duplicate replies
  9P/RDMA: Use a semaphore to protect the RQ
  9P/RDMA: Do not free req->rc in error handling in rdma_request()
  9P/RDMA: Improve error handling in rdma_request
  9P/RDMA: count posted buffers without a pending request
  9P: Add cancelled() to the transport functions.

 include/net/9p/transport.h |    3 +
 net/9p/client.c            |   65 +++++++++++++---------
 net/9p/trans_rdma.c        |  132 ++++++++++++++++++++++++++++----------------
 3 files changed, 126 insertions(+), 74 deletions(-)

-- 
1.7.2.2
