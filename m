From: Patrick McHardy <kaber@trash.net>
Subject: Re: [ANNOUNCE] iproute2 release
Date: Sat, 12 Mar 2005 16:07:23 +0100
Message-ID: <423305AB.7050701@trash.net>
References: <20050310112423.7afdd095@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080803030603010607050504"
Cc: linux-net@vger.kernel.org, netdev@oss.sgi.com, lartc@mailman.ds9a.nl
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050310112423.7afdd095@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080803030603010607050504
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Stephen Hemminger wrote:
> Minor update release for iproute2 is available.

It's missing this patch to use correct values for HZ. If you have
doubts, please say so, I'm not going to resend a fourth time. To
demonstrate the problem:

$ while true; do date; ip -s route get 172.16.195.200; sleep 1; done
Sat Mar 12 15:55:13 CET 2005
172.16.195.200 dev eth0  src 172.16.1.123
     cache  expires 2133437sec users 2 used 18 mtu 1500 advmss 1460 
hoplimit 64
Sat Mar 12 15:55:14 CET 2005
172.16.195.200 dev eth0  src 172.16.1.123
     cache  expires 2133436sec users 1 used 19 mtu 1500 advmss 1460 
hoplimit 64
Sat Mar 12 15:55:15 CET 2005
172.16.195.200 dev eth0  src 172.16.1.123
     cache  expires 2133436sec users 1 used 20 mtu 1500 advmss 1460 
hoplimit 64
Sat Mar 12 15:55:16 CET 2005
172.16.195.200 dev eth0  src 172.16.1.123
     cache  expires 2133436sec users 1 used 21 mtu 1500 advmss 1460 
hoplimit 64
Sat Mar 12 15:55:17 CET 2005
172.16.195.200 dev eth0  src 172.16.1.123
     cache  expires 2133436sec users 1 used 22 mtu 1500 advmss 1460 
hoplimit 64
Sat Mar 12 15:55:18 CET 2005
172.16.195.200 dev eth0  src 172.16.1.123
     cache  expires 2133436sec users 1 used 23 mtu 1500 advmss 1460 
hoplimit 64
Sat Mar 12 15:55:19 CET 2005
172.16.195.200 dev eth0  src 172.16.1.123
     cache  expires 2133436sec users 1 used 24 mtu 1500 advmss 1460 
hoplimit 64
Sat Mar 12 15:55:20 CET 2005
172.16.195.200 dev eth0  src 172.16.1.123
     cache  expires 2133436sec users 1 used 25 mtu 1500 advmss 1460 
hoplimit 64
Sat Mar 12 15:55:21 CET 2005
172.16.195.200 dev eth0  src 172.16.1.123
     cache  expires 2133436sec users 1 used 26 mtu 1500 advmss 1460 
hoplimit 64
Sat Mar 12 15:55:22 CET 2005
172.16.195.200 dev eth0  src 172.16.1.123
     cache  expires 2133436sec users 1 used 27 mtu 1500 advmss 1460 
hoplimit 64
Sat Mar 12 15:55:23 CET 2005
172.16.195.200 dev eth0  src 172.16.1.123
     cache  expires 2133436sec users 1 used 28 mtu 1500 advmss 1460 
hoplimit 64
Sat Mar 12 15:55:24 CET 2005
172.16.195.200 dev eth0  src 172.16.1.123
     cache  expires 2133435sec users 1 used 29 mtu 1500 advmss 1460 
hoplimit 64

--------------080803030603010607050504
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/01/29 10:59:53+01:00 kaber@coreworks.de 
#   Use USER_HZ where necessary
# 
# BitKeeper/etc/logging_ok
#   2005/01/29 10:59:51+01:00 kaber@coreworks.de +1 -0
#   Logging to logging@openlogging.org accepted
# 
# tc/tc_util.c
#   2005/01/29 10:59:48+01:00 kaber@coreworks.de +1 -1
#   Use USER_HZ where necessary
# 
# lib/utils.c
#   2005/01/29 10:59:48+01:00 kaber@coreworks.de +7 -0
#   Use USER_HZ where necessary
# 
# ip/iproute.c
#   2005/01/29 10:59:48+01:00 kaber@coreworks.de +3 -3
#   Use USER_HZ where necessary
# 
# include/utils.h
#   2005/01/29 10:59:48+01:00 kaber@coreworks.de +10 -0
#   Use USER_HZ where necessary
# 
diff -Nru a/include/utils.h b/include/utils.h
--- a/include/utils.h	2005-03-12 15:49:04 +01:00
+++ b/include/utils.h	2005-03-12 15:49:04 +01:00
@@ -113,4 +113,14 @@
 	return __iproute2_hz_internal;
 }
 
+extern int __iproute2_user_hz_internal;
+extern int __get_user_hz(void);
+
+static __inline__ int get_user_hz(void)
+{
+	if (__iproute2_user_hz_internal == 0)
+		__iproute2_user_hz_internal = __get_user_hz();
+	return __iproute2_user_hz_internal;
+}
+
 #endif /* __UTILS_H__ */
diff -Nru a/ip/iproute.c b/ip/iproute.c
--- a/ip/iproute.c	2005-03-12 15:49:04 +01:00
+++ b/ip/iproute.c	2005-03-12 15:49:04 +01:00
@@ -412,7 +412,7 @@
 			struct rta_cacheinfo *ci = RTA_DATA(tb[RTA_CACHEINFO]);
 			static int hz;
 			if (!hz)
-				hz = get_hz();
+				hz = get_user_hz();
 			if (ci->rta_expires != 0)
 				fprintf(fp, " expires %dsec", ci->rta_expires/hz);
 			if (ci->rta_error != 0)
@@ -439,7 +439,7 @@
 		if ((r->rtm_flags & RTM_F_CLONED) || (ci && ci->rta_expires)) {
 			static int hz;
 			if (!hz)
-				hz = get_hz();
+				hz = get_user_hz();
 			if (r->rtm_flags & RTM_F_CLONED)
 				fprintf(fp, "%s    cache ", _SL_);
 			if (ci->rta_expires)
@@ -491,7 +491,7 @@
 			if (i-2 < sizeof(mx_names)/sizeof(char*))
 				fprintf(fp, " %s", mx_names[i-2]);
 			else
-				fprintf(fp, " metric%d", i);
+				fprintf(fp, " metric %d", i);
 			if (mxlock & (1<<i))
 				fprintf(fp, " lock");
 
diff -Nru a/lib/utils.c b/lib/utils.c
--- a/lib/utils.c	2005-03-12 15:49:04 +01:00
+++ b/lib/utils.c	2005-03-12 15:49:04 +01:00
@@ -383,6 +383,13 @@
 	return HZ;
 }
 
+int __iproute2_user_hz_internal;
+
+int __get_user_hz(void)
+{
+	return sysconf(_SC_CLK_TCK);
+}
+
 const char *rt_addr_n2a(int af, int len, const void *addr, char *buf, int buflen)
 {
 	switch (af) {
diff -Nru a/tc/tc_util.c b/tc/tc_util.c
--- a/tc/tc_util.c	2005-03-12 15:49:04 +01:00
+++ b/tc/tc_util.c	2005-03-12 15:49:04 +01:00
@@ -417,7 +417,7 @@
 
 void print_tm(FILE * f, const struct tcf_t *tm)
 {
-	int hz = get_hz();
+	int hz = get_user_hz();
 	if (tm->install != 0)
 		fprintf(f, " installed %d sec", tm->install/hz);
 	if (tm->lastuse != 0)

--------------080803030603010607050504--
