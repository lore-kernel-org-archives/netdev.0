From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [PATCH] pktgen: sprintf arg type warning
Date: Sat, 09 Oct 2004 15:07:03 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41686107.7030508@osdl.org>
References: <20041008203027.643a2a97.rddunlap@osdl.org> <20041008221934.42a6bc7a.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090406030500080203010406"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20041008221934.42a6bc7a.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090406030500080203010406
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

> This won't fix the problem on sparc64 where u64 is an "unsigned long"
> So, just cast the thing to the type gcc wants "unsigned long long"

Yep, I should have known that.  New patch attached.

(Note:  testing new mail client; hopefully it's not munged.)

-- 
~Randy

--------------090406030500080203010406
Content-Type: text/x-patch;
 name="pktgen_type.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="pktgen_type.patch"


Fix printk arg format warning:
net/core/pktgen.c:607: warning: long long unsigned int format, long unsigned int arg (arg 4)

Signed-off-by: Randy Dunlap <rddunlap@osdl.org>

diffstat:=
 net/core/pktgen.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -Naurp ./net/core/pktgen.c~pktgen_type ./net/core/pktgen.c
--- ./net/core/pktgen.c~pktgen_type	2004-10-06 15:04:06.260548504 -0700
+++ ./net/core/pktgen.c	2004-10-09 15:04:10.907452600 -0700
@@ -603,7 +603,7 @@ static void show_results(struct pktgen_i
 	do_div(idle, cpu_speed);
 
 	p += sprintf(p, "OK: %llu(c%llu+d%lu) usec, %llu (%dbyte,%dfrags)\n",
-		     total, total - idle, idle,
+		     total, (unsigned long long)(total - idle), idle,
 		     info->sofar, size, nr_frags);
 
 	pps = info->sofar * USEC_PER_SEC;

--------------090406030500080203010406--
