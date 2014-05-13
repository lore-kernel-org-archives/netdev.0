From: Michael Mueller <mimu@linux.vnet.ibm.com>
Subject: [PATCH v1] vhost: avoid large order allocations
Date: Tue, 13 May 2014 10:35:32 +0200
Message-ID: <1399970133-46783-1-git-send-email-mimu@linux.vnet.ibm.com>
Cc: borntraeger@de.ibm.com, cornelia.huck@de.ibm.com,
	mimu@linux.vnet.ibm.com, ddongch@cn.ibm.com
To: mst@redhat.com, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <kvm-owner@vger.kernel.org>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A test case which generates memory pressure while performing guest administration
fails with vhost triggering "page allocation failure" and guest not starting up.

After some analysis we discovered the allocation order of vhost to be rensponsible
for this behaviour. Thus we suggest patch 1/1 which dynamically allocates the
required memory. Please see its description for details.

Thanks,
Michael 

Dong Dong Chen (1):
  vhost: avoid large order allocations

 drivers/vhost/net.c   | 4 ++--
 drivers/vhost/scsi.c  | 4 ++--
 drivers/vhost/test.c  | 2 +-
 drivers/vhost/vhost.c | 6 +++++-
 drivers/vhost/vhost.h | 2 +-
 5 files changed, 11 insertions(+), 7 deletions(-)

-- 
1.8.3.1

