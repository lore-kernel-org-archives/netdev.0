From: kan.liang@intel.com
Subject: [RFC V3 PATCH 10/26] net/netpolicy: add three new NET policies
Date: Mon, 12 Sep 2016 07:55:43 -0700
Message-ID: <1473692159-4017-11-git-send-email-kan.liang@intel.com>
References: <1473692159-4017-1-git-send-email-kan.liang@intel.com>
Cc: jeffrey.t.kirsher@intel.com, mingo@redhat.com,
        peterz@infradead.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net,
        akpm@linux-foundation.org, keescook@chromium.org,
        viro@zeniv.linux.org.uk, gorcunov@openvz.org,
        john.stultz@linaro.org, aduyck@mirantis.com, ben@decadent.org.uk,
        decot@googlers.com, fw@strlen.de, alexander.duyck@gmail.com,
        daniel@iogearbox.net, tom@herbertland.com, rdunlap@infradead.org,
        xiyou.wangcong@gmail.com, hannes@stressinduktion.org,
        stephen@networkplumber.org, alexei.starovoitov@gmail.com,
        jesse.brandeburg@intel.com, andi@firstfloor.org,
        Kan Liang <kan.liang@intel.com>
To: davem@davemloft.net, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1473692159-4017-1-git-send-email-kan.liang@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kan Liang <kan.liang@intel.com>

Introduce three NET policies
CPU policy: configure for higher throughput and lower CPU% (power
saving).
BULK policy: configure for highest throughput.
LATENCY policy: configure for lowest latency.

Signed-off-by: Kan Liang <kan.liang@intel.com>
---
 include/linux/netpolicy.h | 3 +++
 net/core/netpolicy.c      | 5 ++++-
 2 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/include/linux/netpolicy.h b/include/linux/netpolicy.h
index 8596b6a..951227b 100644
--- a/include/linux/netpolicy.h
+++ b/include/linux/netpolicy.h
@@ -18,6 +18,9 @@
 
 enum netpolicy_name {
 	NET_POLICY_NONE		= 0,
+	NET_POLICY_CPU,
+	NET_POLICY_BULK,
+	NET_POLICY_LATENCY,
 	NET_POLICY_MAX,
 };
 
diff --git a/net/core/netpolicy.c b/net/core/netpolicy.c
index 511d1c6..1d796a8 100644
--- a/net/core/netpolicy.c
+++ b/net/core/netpolicy.c
@@ -226,7 +226,10 @@ static int netpolicy_enable(struct net_device *dev)
 }
 
 const char *policy_name[NET_POLICY_MAX] = {
-	"NONE"
+	"NONE",
+	"CPU",
+	"BULK",
+	"LATENCY"
 };
 
 static u32 cpu_to_queue(struct net_device *dev,
-- 
2.5.5
