From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH] ip link should print NO-CARRIER for !IFF_RUNNING && IFF_UP
Date: Mon, 14 Mar 2005 17:16:21 +0100
Message-ID: <20050314161621.GQ31837@postel.suug.ch>
References: <200503141435.38227.hasso@estpak.ee>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hasso Tepper <hasso@estpak.ee>, netdev@oss.sgi.com
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <200503141435.38227.hasso@estpak.ee>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Till now I thought that IFF_RUNNING flag should be used for that. But some 
> time ago I tried to bug Stephen Hemminger about missing IFF_RUNNING flag in 
> ip output and got answer that IFF_RUNNING is BSD'ism and shouldn't be used 
> any more and /sys/class/net/eth0/carrier should be looked at.

The patch below changes ip link to print NO-CARRIER flag if there is
no carrier and the link is up.

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/03/14 17:12:43+01:00 tgraf@suug.ch 
#   [LINK] Report if link has no carrier
# 
# ip/ipaddress.c
#   2005/03/14 17:12:43+01:00 tgraf@suug.ch +2 -0
#   [LINK] Report if link has no carrier
# 
diff -Nru a/ip/ipaddress.c b/ip/ipaddress.c
--- a/ip/ipaddress.c	2005-03-14 17:13:59 +01:00
+++ b/ip/ipaddress.c	2005-03-14 17:13:59 +01:00
@@ -77,6 +77,8 @@
 void print_link_flags(FILE *fp, unsigned flags, unsigned mdown)
 {
 	fprintf(fp, "<");
+	if (flags & IFF_UP && !(flags & IFF_RUNNING))
+		fprintf(fp, "NO-CARRIER%s", flags ? "," : "");
 	flags &= ~IFF_RUNNING;
 #define _PF(f) if (flags&IFF_##f) { \
                   flags &= ~IFF_##f ; \
