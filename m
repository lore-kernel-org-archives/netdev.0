From: Joe Perches <joe@perches.com>
Subject: [PATCH 04/12] ipconfig: Reduce switch/case indent
Date: Fri,  1 Jul 2011 12:43:05 -0700
Message-ID: <b654246c11d6ead4f640ad669c1e088a6d68883d.1309549244.git.joe@perches.com>
References: <cover.1309549243.git.joe@perches.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yosh
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1309549243.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make the case labels the same indent as the switch.

git diff -w shows miscellaneous 80 column wrapping.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/ipv4/ipconfig.c |   73 ++++++++++++++++++++++++++------------------------
 1 files changed, 38 insertions(+), 35 deletions(-)

diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index ae93dd5..472a8c4 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -861,41 +861,44 @@ static void __init ic_do_bootp_ext(u8 *ext)
 #endif
 
 	switch (*ext++) {
-		case 1:		/* Subnet mask */
-			if (ic_netmask == NONE)
-				memcpy(&ic_netmask, ext+1, 4);
-			break;
-		case 3:		/* Default gateway */
-			if (ic_gateway == NONE)
-				memcpy(&ic_gateway, ext+1, 4);
-			break;
-		case 6:		/* DNS server */
-			servers= *ext/4;
-			if (servers > CONF_NAMESERVERS_MAX)
-				servers = CONF_NAMESERVERS_MAX;
-			for (i = 0; i < servers; i++) {
-				if (ic_nameservers[i] == NONE)
-					memcpy(&ic_nameservers[i], ext+1+4*i, 4);
-			}
-			break;
-		case 12:	/* Host name */
-			ic_bootp_string(utsname()->nodename, ext+1, *ext, __NEW_UTS_LEN);
-			ic_host_name_set = 1;
-			break;
-		case 15:	/* Domain name (DNS) */
-			ic_bootp_string(ic_domain, ext+1, *ext, sizeof(ic_domain));
-			break;
-		case 17:	/* Root path */
-			if (!root_server_path[0])
-				ic_bootp_string(root_server_path, ext+1, *ext, sizeof(root_server_path));
-			break;
-		case 26:	/* Interface MTU */
-			memcpy(&mtu, ext+1, sizeof(mtu));
-			ic_dev_mtu = ntohs(mtu);
-			break;
-		case 40:	/* NIS Domain name (_not_ DNS) */
-			ic_bootp_string(utsname()->domainname, ext+1, *ext, __NEW_UTS_LEN);
-			break;
+	case 1:		/* Subnet mask */
+		if (ic_netmask == NONE)
+			memcpy(&ic_netmask, ext+1, 4);
+		break;
+	case 3:		/* Default gateway */
+		if (ic_gateway == NONE)
+			memcpy(&ic_gateway, ext+1, 4);
+		break;
+	case 6:		/* DNS server */
+		servers= *ext/4;
+		if (servers > CONF_NAMESERVERS_MAX)
+			servers = CONF_NAMESERVERS_MAX;
+		for (i = 0; i < servers; i++) {
+			if (ic_nameservers[i] == NONE)
+				memcpy(&ic_nameservers[i], ext+1+4*i, 4);
+		}
+		break;
+	case 12:	/* Host name */
+		ic_bootp_string(utsname()->nodename, ext+1, *ext,
+				__NEW_UTS_LEN);
+		ic_host_name_set = 1;
+		break;
+	case 15:	/* Domain name (DNS) */
+		ic_bootp_string(ic_domain, ext+1, *ext, sizeof(ic_domain));
+		break;
+	case 17:	/* Root path */
+		if (!root_server_path[0])
+			ic_bootp_string(root_server_path, ext+1, *ext,
+					sizeof(root_server_path));
+		break;
+	case 26:	/* Interface MTU */
+		memcpy(&mtu, ext+1, sizeof(mtu));
+		ic_dev_mtu = ntohs(mtu);
+		break;
+	case 40:	/* NIS Domain name (_not_ DNS) */
+		ic_bootp_string(utsname()->domainname, ext+1, *ext,
+				__NEW_UTS_LEN);
+		break;
 	}
 }
 
-- 
1.7.6.rc1
