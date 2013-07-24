From: Francesco Fusco <ffusco@redhat.com>
Subject: [PATCH net-next v2 2/2] sysctl: range checking in do_proc_dointvec_ms_jiffies_conv
Date: Wed, 24 Jul 2013 16:52:34 +0200
Message-ID: <157b21242b8fbe7c9c454827a7c49eb19ea9873b.1374677178.git.ffusco@redhat.com>
References: <cover.1374677178.git.ffusco@redhat.com>
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1374677178.git.ffusco@redhat.com>
In-Reply-To: <cover.1374677178.git.ffusco@redhat.com>
References: <cover.1374677178.git.ffusco@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When (integer) sysctl values are expressed in ms and have to be
represented internally as jiffies. The msecs_to_jiffies function
returns an unsigned long, which gets assigned to the integer.
This patch prevents the value to be assigned if bigger than
INT_MAX, done in a similar way as in cba9f3 ("Range checking in
do_proc_dointvec_(userhz_)jiffies_conv").

Signed-off-by: Francesco Fusco <ffusco@redhat.com>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: linux-kernel@vger.kernel.org
---
 v1 => v2 
 - fix style suggested by Sergei Shtylyov

 kernel/sysctl.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index ac09d98..07f6fc4 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -2346,7 +2346,11 @@ static int do_proc_dointvec_ms_jiffies_conv(bool *negp, unsigned long *lvalp,
 					    int write, void *data)
 {
 	if (write) {
-		*valp = msecs_to_jiffies(*negp ? -*lvalp : *lvalp);
+		unsigned long jif = msecs_to_jiffies(*negp ? -*lvalp : *lvalp);
+
+		if (jif > INT_MAX)
+			return 1;
+		*valp = (int)jif;
 	} else {
 		int val = *valp;
 		unsigned long lval;
-- 
1.8.3.1
