From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH] ipconfig: send host-name in DHCP requests
Date: Mon, 31 May 2010 11:19:53 +0800
Message-ID: <20100531031953.GA10590@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>,
	Andi Kleen <andi@firstfloor.org>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Normally dhclient can be configured to send the "host-name" option
in DHCP requests to update the client's DNS record. However for an
NFSROOT system, dhclient shall never be called (which may change the
IP addr and therefore lose your root NFS mount connection).

So enable updating the DNS record with kernel parameter

	ip=::::$HOST_NAME::dhcp

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 net/ipv4/ipconfig.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index 067ce9e..db54343 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -665,6 +665,13 @@ ic_dhcp_init_options(u8 *options)
 		memcpy(e, ic_req_params, sizeof(ic_req_params));
 		e += sizeof(ic_req_params);
 
+		if (ic_host_name_set) {
+			*e++ = 12;	/* host-name */
+			len = strlen(utsname()->nodename);
+			*e++ = len;
+			memcpy(e, utsname()->nodename, len);
+			e += len;
+		}
 		if (*vendor_class_identifier) {
 			printk(KERN_INFO "DHCP: sending class identifier \"%s\"\n",
 			       vendor_class_identifier);
-- 
1.6.6
