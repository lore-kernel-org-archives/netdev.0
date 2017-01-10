From: Juergen Gross <jgross@suse.com>
Subject: [PATCH 0/2] xen/net: limit number of tx/rx queues
Date: Tue, 10 Jan 2017 14:32:50 +0100
Message-ID: <20170110133252.5346-1-jgross@suse.com>
Cc: boris.ostrovsky@oracle.com, wei.liu2@citrix.com,
        paul.durrant@citrix.com, Juergen Gross <jgross@suse.com>
To: linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Xen network frontend/backend supports multiple tx/rx queues for one
virtual interface. The number of queues supported by the backend is
set to the number of cpus of the backend driver domain (usually dom0)
and the number of queues requested by the frontend is limited by the
number of vcpus of the related guest.

On large systems this can lead to ridiculous large number of queues
exhausting the required number of grant pages rather quick.

To avoid this limit the default maximum on both sides to 8. Both
frontend and backend maximum can be individually tuned via module
parameters.

Juergen Gross (2):
  xen/netfront: set default upper limit of tx/rx queues to 8
  xen/netback: set default upper limit of tx/rx queues to 8

 drivers/net/xen-netback/netback.c | 6 ++++--
 drivers/net/xen-netfront.c        | 6 ++++--
 2 files changed, 8 insertions(+), 4 deletions(-)

-- 
2.10.2
