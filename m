From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH 2/5] if_tun: add TUNSETVNETLE/TUNGETVNETLE
Date: Tue, 16 Dec 2014 15:05:01 +0200
Message-ID: <1418732988-3535-3-git-send-email-mst@redhat.com>
References: <1418732988-3535-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Dan Carpenter <dan.carpenter@oracle.com>,
	linux-api@vger.kernel.org, Jason Wang <jasowang@redhat.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1418732988-3535-1-git-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ifreq flags field is only 16 bit wide, so setting IFF_VNET_LE there has
no effect:
doesn't fit in two bytes.

The tests passed apparently because they have an even number of bugs,
all cancelling out.

Luckily we didn't release a kernel with this flag, so it's
not too late to fix this.

Add TUNSETVNETLE/TUNGETVNETLE to really achieve the purpose
of IFF_VNET_LE.

This has an added benefit that if we ever want a BE flag,
we won't have to deal with weird configurations like
setting both LE and BE at the same time.

IFF_VNET_LE will be dropped in a follow-up patch.

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 include/uapi/linux/if_tun.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/uapi/linux/if_tun.h b/include/uapi/linux/if_tun.h
index 18b2403..274630c 100644
--- a/include/uapi/linux/if_tun.h
+++ b/include/uapi/linux/if_tun.h
@@ -48,6 +48,8 @@
 #define TUNSETQUEUE  _IOW('T', 217, int)
 #define TUNSETIFINDEX	_IOW('T', 218, unsigned int)
 #define TUNGETFILTER _IOR('T', 219, struct sock_fprog)
+#define TUNSETVNETLE _IOW('T', 220, int)
+#define TUNGETVNETLE _IOR('T', 221, int)
 
 /* TUNSETIFF ifr flags */
 #define IFF_TUN		0x0001
-- 
MST
