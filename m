From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: [PATCH] pktgen: reduce stack usage
Date: Tue, 22 Feb 2005 16:41:31 +0100
Message-ID: <16923.21163.112945.608974@robur.slu.se>
References: <20050218134219.3f079110.rddunlap@osdl.org>
	<20050218221121.GA22845@electric-eye.fr.zoreil.com>
	<42166E3F.2050304@osdl.org>
	<16921.60572.951532.31861@robur.slu.se>
	<421A0880.5070205@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Randy.Dunlap" <rddunlap@osdl.org>,
        Robert Olsson <Robert.Olsson@data.slu.se>,
        Francois Romieu <romieu@fr.zoreil.com>, netdev <netdev@oss.sgi.com>
To: davem@davemloft.net
In-Reply-To: <421A0880.5070205@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Randy.Dunlap writes:
 > >  Here is version with just one buffer.
 > 
 > Yep, even better:  few changes + using sizeof.

 Hello.

 OK! Then we ask DaveM to apply the patch.

				    --ro


 
--- net/core/pktgen.c.050221	2005-02-21 14:02:40.000000000 +0100
+++ net/core/pktgen.c	2005-02-21 15:02:44.000000000 +0100
@@ -151,7 +151,7 @@
 #include <asm/timex.h>
 
 
-#define VERSION  "pktgen v2.57: Packet Generator for packet performance testing.\n"
+#define VERSION  "pktgen v2.58: Packet Generator for packet performance testing.\n"
 
 /* #define PG_DEBUG(a) a */
 #define PG_DEBUG(a) 
@@ -811,6 +811,7 @@
         struct pktgen_dev *pkt_dev = (struct pktgen_dev*)(data);
         char* pg_result = NULL;
         int tmp = 0;
+	char buf[128];
         
         pg_result = &(pkt_dev->result[0]);
         
@@ -1071,7 +1072,6 @@
 		return count;
 	}
 	if (!strcmp(name, "dst_min") || !strcmp(name, "dst")) {
-                char buf[IP_NAME_SZ];
 		len = strn_len(&user_buffer[i], sizeof(pkt_dev->dst_min) - 1);
                 if (len < 0) { return len; }
 
@@ -1091,7 +1091,6 @@
 		return count;
 	}
 	if (!strcmp(name, "dst_max")) {
-                char buf[IP_NAME_SZ];
 		len = strn_len(&user_buffer[i], sizeof(pkt_dev->dst_max) - 1);
                 if (len < 0) { return len; }
 
@@ -1112,9 +1111,7 @@
 		return count;
 	}
 	if (!strcmp(name, "dst6")) {
-                char buf[128];
-
-		len = strn_len(&user_buffer[i], 128 - 1);
+		len = strn_len(&user_buffer[i], sizeof(buf) - 1);
                 if (len < 0) return len; 
 
 		pkt_dev->flags |= F_IPV6;
@@ -1136,9 +1133,7 @@
 		return count;
 	}
 	if (!strcmp(name, "dst6_min")) {
-                char buf[128];
-
-		len = strn_len(&user_buffer[i], 128 - 1);
+		len = strn_len(&user_buffer[i], sizeof(buf) - 1);
                 if (len < 0) return len; 
 
 		pkt_dev->flags |= F_IPV6;
@@ -1159,9 +1154,7 @@
 		return count;
 	}
 	if (!strcmp(name, "dst6_max")) {
-                char buf[128];
-
-		len = strn_len(&user_buffer[i], 128 - 1);
+		len = strn_len(&user_buffer[i], sizeof(buf) - 1);
                 if (len < 0) return len; 
 
 		pkt_dev->flags |= F_IPV6;
@@ -1181,9 +1174,7 @@
 		return count;
 	}
 	if (!strcmp(name, "src6")) {
-                char buf[128];
-
-		len = strn_len(&user_buffer[i], 128 - 1);
+		len = strn_len(&user_buffer[i], sizeof(buf) - 1);
                 if (len < 0) return len; 
 
 		pkt_dev->flags |= F_IPV6;
@@ -1205,7 +1196,6 @@
 		return count;
 	}
 	if (!strcmp(name, "src_min")) {
-                char buf[IP_NAME_SZ];
 		len = strn_len(&user_buffer[i], sizeof(pkt_dev->src_min) - 1);
                 if (len < 0) { return len; }
                 if (copy_from_user(buf, &user_buffer[i], len))
@@ -1224,7 +1214,6 @@
 		return count;
 	}
 	if (!strcmp(name, "src_max")) {
-                char buf[IP_NAME_SZ];
 		len = strn_len(&user_buffer[i], sizeof(pkt_dev->src_max) - 1);
                 if (len < 0) { return len; }
                 if (copy_from_user(buf, &user_buffer[i], len))
