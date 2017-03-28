From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 6/7] net:mpls: Refactor mpls_netconf_notify_devconf to take event
Date: Tue, 28 Mar 2017 14:28:06 -0700
Message-ID: <1490736487-16020-7-git-send-email-dsa@cumulusnetworks.com>
References: <1490736487-16020-1-git-send-email-dsa@cumulusnetworks.com>
Cc: nicolas.dichtel@6wind.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f52.google.com ([209.85.214.52]:35993 "EHLO
        mail-it0-f52.google.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753422AbdC1V2q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 17:28:46 -0400
Received: by mail-it0-f52.google.com with SMTP id e75so71440758itd.1
        for <netdev@vger.kernel.org>; Tue, 28 Mar 2017 14:28:46 -0700 (PDT)
In-Reply-To: <1490736487-16020-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Refactor mpls_netconf_notify_devconf to take the event as an input arg.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/mpls/af_mpls.c | 12 +++++-------
 1 file changed, 5 insertions(+), 7 deletions(-)

diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index 74755920c689..313cd0a93a63 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -1040,8 +1040,8 @@ static int mpls_netconf_msgsize_devconf(int type)
 	return size;
 }
 
-static void mpls_netconf_notify_devconf(struct net *net, int type,
-					struct mpls_dev *mdev)
+static void mpls_netconf_notify_devconf(struct net *net, int event,
+					int type, struct mpls_dev *mdev)
 {
 	struct sk_buff *skb;
 	int err = -ENOBUFS;
@@ -1050,8 +1050,7 @@ static void mpls_netconf_notify_devconf(struct net *net, int type,
 	if (!skb)
 		goto errout;
 
-	err = mpls_netconf_fill_devconf(skb, mdev, 0, 0, RTM_NEWNETCONF,
-					0, type);
+	err = mpls_netconf_fill_devconf(skb, mdev, 0, 0, event, 0, type);
 	if (err < 0) {
 		/* -EMSGSIZE implies BUG in mpls_netconf_msgsize_devconf() */
 		WARN_ON(err == -EMSGSIZE);
@@ -1184,9 +1183,8 @@ static int mpls_conf_proc(struct ctl_table *ctl, int write,
 
 		if (i == offsetof(struct mpls_dev, input_enabled) &&
 		    val != oval) {
-			mpls_netconf_notify_devconf(net,
-						    NETCONFA_INPUT,
-						    mdev);
+			mpls_netconf_notify_devconf(net, RTM_NEWNETCONF,
+						    NETCONFA_INPUT, mdev);
 		}
 	}
 
-- 
2.1.4
