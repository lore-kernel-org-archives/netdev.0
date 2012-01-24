From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: [PATCH iproute2 2/2] netem: Fix 'reorder' section of man page
Date: Mon, 23 Jan 2012 22:08:52 -0800
Message-ID: <1327385332-20776-3-git-send-email-subramanian.vijay@gmail.com>
References: <1327385332-20776-1-git-send-email-subramanian.vijay@gmail.com>
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Vijay Subramanian <subramanian.vijay@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:46284 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751235Ab2AXGJr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2012 01:09:47 -0500
Received: by mail-iy0-f174.google.com with SMTP id b35so4878275iac.19
        for <netdev@vger.kernel.org>; Mon, 23 Jan 2012 22:09:47 -0800 (PST)
In-Reply-To: <1327385332-20776-1-git-send-email-subramanian.vijay@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The syntax used in the example on reordering in the manpage is inconsistent with
the usage syntax.  Moreover, the text does not describe the reordering process
in the kernel correctly. This patch fixes these two issues.

Signed-off-by: Vijay Subramanian <subramanian.vijay@gmail.com>
---
 man/man8/tc-netem.8 |   20 ++++++++++++++------
 1 files changed, 14 insertions(+), 6 deletions(-)

diff --git a/man/man8/tc-netem.8 b/man/man8/tc-netem.8
index b36d0ec..39f8454 100644
--- a/man/man8/tc-netem.8
+++ b/man/man8/tc-netem.8
@@ -112,19 +112,27 @@ using this option the chosen percent of packets is duplicated before queuing
 them. It is also possible to add a correlation through the proper parameter.
 
 .SS reorder
-there are two ways to use this option:
+to use reordering, a delay option must be specified. There are two ways to use
+this option (assuming 'delay 10ms' in the options list).
 
-.B "reorder gap"
-.I 5 10
+.B "reorder "
+.I 25% 50%
+.B "gap"
+.I 5
 .br
-in this first example every 5th (10th, 15th) packet is sent immediately while
-other packets are delayed by 10 ms
+in this first example, the first 4 (gap - 1) packets are delayed by 10ms and
+subsequent packets are sent immediately with a probability of 0.25 (with
+correlation of 50% ) or delayed with a probability of 0.75. After a packet is
+reordered, the process restarts i.e. the next 4 packets are delayed and
+subsequent packets are sent immediately or delayed based on reordering
+probability. To cause a repeatable pattern where every 5th packet is reordered
+reliably, a reorder probability of 100% can be used.
 
 .B reorder
 .I 25% 50%
 .br
 in this second example 25% of packets are sent immediately (with correlation of
-50%) while the other are delayed by 10 ms.
+50%) while the others are delayed by 10 ms.
 
 .SS rate
 delay packets based on packet size and is a replacement for 
-- 
1.7.0.4
