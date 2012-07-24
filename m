From: "K. Y. Srinivasan" <kys@microsoft.com>
Subject: [PATCH 11/17] Tools: hv: Gather DNS information
Date: Tue, 24 Jul 2012 09:01:35 -0700
Message-ID: <1343145701-3691-11-git-send-email-kys@microsoft.com>
References: <1343145672-3641-1-git-send-email-kys@microsoft.com>
 <1343145701-3691-1-git-send-email-kys@microsoft.com>
Cc: "K. Y. Srinivasan" <kys@microsoft.com>
To: gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org,
	devel@linuxdriverproject.org, virtualization@lists.osdl.org,
	olaf@aepfle.de, apw@canonical.com, netdev@vger.kernel.org,
	ben@decadent.org.uk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1343145701-3691-1-git-send-email-kys@microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now gather DNS information. This information cannot be gathered in
a distro independent fashion. Invoke an external script (that can be
distro dependent) to gather the DNS information.

Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
Reviewed-by: Haiyang Zhang <haiyangz@microsoft.com>
---
 tools/hv/hv_kvp_daemon.c |   27 +++++++++++++++++++++++++++
 1 files changed, 27 insertions(+), 0 deletions(-)

diff --git a/tools/hv/hv_kvp_daemon.c b/tools/hv/hv_kvp_daemon.c
index b627236..9500cff 100644
--- a/tools/hv/hv_kvp_daemon.c
+++ b/tools/hv/hv_kvp_daemon.c
@@ -554,6 +554,33 @@ static void kvp_get_ipconfig_info(char *if_name,
 	kvp_process_ipconfig_file(cmd, (char *)buffer->gate_way,
 				(MAX_GATEWAY_SIZE * 2), INET6_ADDRSTRLEN, 1);
 
+
+	/*
+	 * Gather the DNS  state.
+	 * Since there is no standard way to get this information
+	 * across various distributions of interest; we just invoke
+	 * an external script that needs to be ported across distros
+	 * of interest.
+	 * Input to the script:
+	 * 1) Interface name
+	 *
+	 * Following is the expected format of the information from the script:
+	 *
+	 * ipaddr1 (nameserver1)
+	 * ipaddr2 (nameserver2)
+	 * .
+	 * .
+	 */
+
+	memset(cmd, 0, sizeof(cmd));
+	strcat(cmd, "/sbin/hv_get_dns_info ");
+	strcat(cmd, if_name);
+
+	/*
+	 * Execute the command to gather DNS info.
+	 */
+	kvp_process_ipconfig_file(cmd, (char *)buffer->dns_addr,
+				(MAX_IP_ADDR_SIZE * 2), INET_ADDRSTRLEN, 0);
 }
 
 
-- 
1.7.4.1
