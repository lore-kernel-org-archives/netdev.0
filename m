From: Richard Guy Briggs <rgb@redhat.com>
Subject: [PATCH 6/6][v2] audit: send multicast messages only if there are listeners
Date: Tue, 22 Apr 2014 21:31:58 -0400
Message-ID: <e131257eeebff6e2da08486ffd9146eb99ee8f61.1398215388.git.rgb@redhat.com>
References: <20140422.161904.1187535812839850973.davem@davemloft.net>
Cc: Richard Guy Briggs <rgb@redhat.com>, davem@davemloft.net,
	jamal@mojatatu.com, eparis@redhat.com, sgrubb@redhat.com
To: linux-audit@redhat.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, selinux@tycho.nsa.gov,
	linux-security-module@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140422.161904.1187535812839850973.davem@davemloft.net>
In-Reply-To: <cover.1398215388.git.rgb@redhat.com>
References: <cover.1398215388.git.rgb@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Test first to see if there are any userspace multicast listeners bound to the
socket before starting the multicast send work.

Signed-off-by: Richard Guy Briggs <rgb@redhat.com>
---
 kernel/audit.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/kernel/audit.c b/kernel/audit.c
index d272cc1..33531d7 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -435,6 +435,9 @@ static void kauditd_send_multicast_skb(struct sk_buff *skb)
 	struct audit_net	*aunet = net_generic(&init_net, audit_net_id);
 	struct sock		*sock = aunet->nlsk;
 
+	if (!netlink_has_listeners(sock, AUDIT_NLGRP_READLOG))
+		return;
+
 	/*
 	 * The seemingly wasteful skb_copy() rather than bumping the refcount
 	 * using skb_get() is necessary because non-standard mods are made to
-- 
1.7.1
