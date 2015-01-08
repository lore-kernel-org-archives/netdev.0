From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] netfilter: nat_snmp_basic: Use generic dump
 facility
Date: Thu, 08 Jan 2015 09:56:43 -0800
Message-ID: <1420739803.11784.7.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the generic facility instead of a static hex_dump routine.
Delete the now unused static routine.

Now emits the hex dump at KERN_DEBUG instead of default.

Shrinks the kernel ever so trivially.

$ size net/ipv4/netfilter/nf_nat_snmp_basic.o*
   text	   data	    bss	    dec	    hex	filename
   5948	    352	      8	   6308	   18a4	net/ipv4/netfilter/nf_nat_snmp_basic.o.defconfig.new
   5985	    352	      8	   6345	   18c9	net/ipv4/netfilter/nf_nat_snmp_basic.o.defconfig.old

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/ipv4/netfilter/nf_nat_snmp_basic.c | 14 +-------------
 1 file changed, 1 insertion(+), 13 deletions(-)

diff --git a/net/ipv4/netfilter/nf_nat_snmp_basic.c b/net/ipv4/netfilter/nf_nat_snmp_basic.c
index 7c67667..5c8d3b5 100644
--- a/net/ipv4/netfilter/nf_nat_snmp_basic.c
+++ b/net/ipv4/netfilter/nf_nat_snmp_basic.c
@@ -998,18 +998,6 @@ err_id_free:
  *
  *****************************************************************************/
 
-static void hex_dump(const unsigned char *buf, size_t len)
-{
-	size_t i;
-
-	for (i = 0; i < len; i++) {
-		if (i && !(i % 16))
-			printk("\n");
-		printk("%02x ", *(buf + i));
-	}
-	printk("\n");
-}
-
 /*
  * Parse and mangle SNMP message according to mapping.
  * (And this is the fucking 'basic' method).
@@ -1026,7 +1014,7 @@ static int snmp_parse_mangle(unsigned char *msg,
 	struct snmp_object *obj;
 
 	if (debug > 1)
-		hex_dump(msg, len);
+		print_hex_dump_bytes("", DUMP_PREFIX_NONE, msg, len);
 
 	asn1_open(&ctx, msg, len);
 
