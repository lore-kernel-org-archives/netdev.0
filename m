From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: [PATCH] LLC: fix procfs reading when there are saps without sockets
Date: Sat, 1 Nov 2003 04:55:04 -0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031101065504.GK3705@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Networking Development Mailing List <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi David,

	Noticed while on a ssh over PF_LLC session on a machine that had
Appletalk/SNAP running, doing a cat /proc/net/llc/socket returned nothing
when there were the sshd listening socket and the ssh connection. Just
removing this anyway uneeded test fix this bug. Please apply.

Best Regards,

- Arnaldo

===== net/llc/llc_proc.c 1.20 vs edited =====
--- 1.20/net/llc/llc_proc.c	Thu Oct 30 16:35:41 2003
+++ edited/net/llc/llc_proc.c	Sat Nov  1 04:48:06 2003
@@ -48,8 +48,6 @@
 			--pos;
 		}
 		read_unlock_bh(&sap->sk_list.lock);
-		if (!pos)
-			break;
 	}
 	sk = NULL;
 found:
