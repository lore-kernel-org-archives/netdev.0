From: Michal Schmidt <mschmidt@redhat.com>
Subject: [PATCH net-next 0/3] bnx2x: minimize RAM usage in kdump
Date: Tue, 25 Feb 2014 16:04:23 +0100
Message-ID: <1393340666-3539-1-git-send-email-mschmidt@redhat.com>
Cc: netdev@vger.kernel.org, ariele@broadcom.com, dmitry@broadcom.com,
	yuvalmin@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9044 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752072AbaBYPEc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Feb 2014 10:04:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

kdump kernels usually have only a small amount of memory reserved.
bnx2x can be memory-hungry. Let's minimize its memory usage when
running in kdump.

I detect kdump by looking at the "reset_devices" flag. A couple of
storage drivers (cciss, hpsa) use it for the same purpose. I am not sure
this is the best way to solve the problem, but it works.

Should it be made more generic by, say, looking at the total amount
of lowmem instead? Not using TPA by default when lowmem is small and/or
defaulting to fewer queues would help 32bit systems where a driver for
a multi-function multi-queue NIC can consume a significant amount
of available memory. Or do we want no such heuristics?

Is this something to consider doing for other network drivers too?

Michal Schmidt (3):
  bnx2x: clamp num_queues to prevent passing a negative value
  bnx2x: save RAM in kdump kernel by using a single queue
  bnx2x: save RAM in kdump kernel by disabling TPA

 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c  | 12 ++++++++----
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |  2 ++
 2 files changed, 10 insertions(+), 4 deletions(-)

-- 
1.8.5.3
