From: David Decotigny <decot@google.com>
Subject: [PATCH] acenic: Fix using the specified speed when configuring NIC
Date: Sat, 16 Apr 2011 17:57:07 -0700
Message-ID: <1303001827-4283-1-git-send-email-decot@google.com>
Cc: David Decotigny <decot@google.com>
To: Jes Sorensen <jes@trained-monkey.org>, linux-acenic@sunsite.dk,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:15193 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753395Ab1DQA5P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Apr 2011 20:57:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch needs review, as I did not test it: I only think something
is weird by looking at the code, but experts must confirm.

This tells the NIC to take the speed specified by ethtool into account
when configuring the NIC, instead of keeping the previous speed.

Signed-off-by: David Decotigny <decot@google.com>
---
 drivers/net/acenic.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/acenic.c b/drivers/net/acenic.c
index a579899..82260ca 100644
--- a/drivers/net/acenic.c
+++ b/drivers/net/acenic.c
@@ -2720,7 +2720,7 @@ static int ace_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 		link |= LNK_NEGOTIATE;
 	if (ethtool_cmd_speed(ecmd) != speed) {
 		link &= ~(LNK_1000MB | LNK_100MB | LNK_10MB);
-		switch (speed) {
+		switch (ethtool_cmd_speed(ecmd)) {
 		case SPEED_1000:
 			link |= LNK_1000MB;
 			break;
-- 
1.7.3.1

