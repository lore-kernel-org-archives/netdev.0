From: Vitaliy Gusev <vgusev@openvz.org>
Subject: [PATCH] Fix lost export-dynamic
Date: Mon, 17 Dec 2007 16:06:38 +0300
Message-ID: <200712171606.38546.vgusev@openvz.org>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_eRnZHFejv8gkZrH"
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:15689 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755472AbXLQN31 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Dec 2007 08:29:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Boundary-00=_eRnZHFejv8gkZrH
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

get_link_kind() fails for statically linked modules (vlan, veth, etc.) if "ip" 
was linked without "export-dynamic".

Signed-off-by: Vitaliy Gusev <vgusev@openvz.org>

-- 
Thank,
Vitaliy Gusev

--Boundary-00=_eRnZHFejv8gkZrH
Content-Type: text/plain;
  charset="us-ascii";
  name="diff-add-export-dynamic.patch"
Content-Transfer-Encoding: 8bit
Content-Disposition: inline;
	filename="diff-add-export-dynamic.patch"

diff --git a/ip/Makefile b/ip/Makefile
index 448efb9..b427d58 100644
--- a/ip/Makefile
+++ b/ip/Makefile
@@ -24,3 +24,5 @@ clean:
 	rm -f $(ALLOBJ) $(TARGETS)
 
 LDLIBS += -ldl
+
+LDFLAGS += -Wl,-export-dynamic

--Boundary-00=_eRnZHFejv8gkZrH--
