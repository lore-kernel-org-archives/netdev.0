From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH 05/10] pktgen: make /proc/net/pktgen/pgctrl report
	fail on invalid input
Date: Tue, 19 May 2015 23:35:58 +0200
Message-ID: <20150519213558.9070.58080.stgit@ivy>
References: <20150519213326.9070.18264.stgit@ivy>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	Daniel Borkmann <borkmann@iogearbox.net>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Robert Olsson <robert@herjulf.se>,
	Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33153 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751761AbbESVg1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 May 2015 17:36:27 -0400
In-Reply-To: <20150519213326.9070.18264.stgit@ivy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Giving /proc/net/pktgen/pgctrl an invalid command just returns shell
success and prints a warning in dmesg.  This is not very useful for
shell scripting, as it can only detect the error by parsing dmesg.

Instead return -EINVAL when the command is unknown, as this provides
userspace shell scripting a way of detecting this.

Also bump version tag to 2.75, because (1) reading /proc/net/pktgen/pgctrl
output this version number which would allow to detect this small
semantic change, and (2) because the pktgen version tag have not been
updated since 2010.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---

 net/core/pktgen.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 167e592..676550f 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -177,7 +177,7 @@
 #include <asm/dma.h>
 #include <asm/div64.h>		/* do_div */
 
-#define VERSION	"2.74"
+#define VERSION	"2.75"
 #define IP_NAME_SZ 32
 #define MAX_MPLS_LABELS 16 /* This is the max label stack depth */
 #define MPLS_STACK_BOTTOM htonl(0x00000100)
@@ -512,7 +512,7 @@ static ssize_t pgctrl_write(struct file *file, const char __user *buf,
 		pktgen_reset_all_threads(pn);
 
 	else
-		pr_warn("Unknown command: %s\n", data);
+		return -EINVAL;
 
 	return count;
 }
