From: Amir Noam <amir.noam@intel.com>
Subject: [PATCH 3/10] [bonding 2.6] fix ARP monitoring bug
Date: Thu, 4 Sep 2003 20:44:25 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309042044.25278.amir.noam@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
To: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -Nuarp a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
--- a/drivers/net/bonding/bond_main.c	Thu Sep  4 20:17:57 2003
+++ b/drivers/net/bonding/bond_main.c	Thu Sep  4 20:17:58 2003
@@ -443,7 +443,7 @@ struct bond_parm_tbl {
 
 static int arp_interval = BOND_LINK_ARP_INTERV;
 static char *arp_ip_target[MAX_ARP_IP_TARGETS] = { NULL, };
-static unsigned long arp_target[MAX_ARP_IP_TARGETS] = { 0, } ;
+static u32 arp_target[MAX_ARP_IP_TARGETS] = { 0, } ;
 static int arp_ip_count = 0;
 static u32 my_ip = 0;
 char *arp_target_hw_addr = NULL;
@@ -3811,7 +3811,7 @@ static int __init bonding_init(void)
                         arp_interval = 0;
 		} else { 
 			u32 ip = in_aton(arp_ip_target[arp_ip_count]); 
-			*(u32 *)(arp_ip_target[arp_ip_count]) = ip;
+			arp_target[arp_ip_count] = ip;
 		}
         }
 
