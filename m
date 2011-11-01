From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 16/21] Replace global devname variable with a field
 in struct cmd_context
Date: Tue, 1 Nov 2011 23:20:04 +0000
Message-ID: <1320189604.2758.46.camel@bwh-desktop>
References: <1320186901.2758.30.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-net-drivers@solarflare.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:38537 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932086Ab1KAXUH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2011 19:20:07 -0400
In-Reply-To: <1320186901.2758.30.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 ethtool.c  |   24 +++++++++++-------------
 internal.h |    1 +
 2 files changed, 12 insertions(+), 13 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index 438fc26..d0929c7 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -285,8 +285,6 @@ static int show_usage(struct cmd_context *ctx)
 	return 0;
 }
 
-static char *devname = NULL;
-
 static int goffload_changed = 0;
 static int off_csum_rx_wanted = -1;
 static int off_csum_tx_wanted = -1;
@@ -1540,7 +1538,7 @@ static int do_gpause(struct cmd_context *ctx)
 	if (ctx->argc != 0)
 		exit_bad_args();
 
-	fprintf(stdout, "Pause parameters for %s:\n", devname);
+	fprintf(stdout, "Pause parameters for %s:\n", ctx->devname);
 
 	epause.cmd = ETHTOOL_GPAUSEPARAM;
 	err = send_ioctl(ctx, &epause);
@@ -1662,7 +1660,7 @@ static int do_gring(struct cmd_context *ctx)
 	if (ctx->argc != 0)
 		exit_bad_args();
 
-	fprintf(stdout, "Ring parameters for %s:\n", devname);
+	fprintf(stdout, "Ring parameters for %s:\n", ctx->devname);
 
 	ering.cmd = ETHTOOL_GRINGPARAM;
 	err = send_ioctl(ctx, &ering);
@@ -1721,7 +1719,7 @@ static int do_gchannels(struct cmd_context *ctx)
 	if (ctx->argc != 0)
 		exit_bad_args();
 
-	fprintf(stdout, "Channel parameters for %s:\n", devname);
+	fprintf(stdout, "Channel parameters for %s:\n", ctx->devname);
 
 	echannels.cmd = ETHTOOL_GCHANNELS;
 	err = send_ioctl(ctx, &echannels);
@@ -1744,7 +1742,7 @@ static int do_gcoalesce(struct cmd_context *ctx)
 	if (ctx->argc != 0)
 		exit_bad_args();
 
-	fprintf(stdout, "Coalesce parameters for %s:\n", devname);
+	fprintf(stdout, "Coalesce parameters for %s:\n", ctx->devname);
 
 	ecoal.cmd = ETHTOOL_GCOALESCE;
 	err = send_ioctl(ctx, &ecoal);
@@ -1802,7 +1800,7 @@ static int do_goffload(struct cmd_context *ctx)
 	if (ctx->argc != 0)
 		exit_bad_args();
 
-	fprintf(stdout, "Offload parameters for %s:\n", devname);
+	fprintf(stdout, "Offload parameters for %s:\n", ctx->devname);
 
 	eval.cmd = ETHTOOL_GRXCSUM;
 	err = send_ioctl(ctx, &eval);
@@ -2009,7 +2007,7 @@ static int do_gset(struct cmd_context *ctx)
 	if (ctx->argc != 0)
 		exit_bad_args();
 
-	fprintf(stdout, "Settings for %s:\n", devname);
+	fprintf(stdout, "Settings for %s:\n", ctx->devname);
 
 	ecmd.cmd = ETHTOOL_GSET;
 	err = send_ioctl(ctx, &ecmd);
@@ -2744,7 +2742,7 @@ static int do_grxfhindir(struct cmd_context *ctx)
 	}
 
 	printf("RX flow hash indirection table for %s with %llu RX ring(s):\n",
-	       devname, ring_count.data);
+	       ctx->devname, ring_count.data);
 	for (i = 0; i < indir->size; i++) {
 		if (i % 8 == 0)
 			printf("%5u: ", i);
@@ -3222,17 +3220,17 @@ int main(int argc, char **argp, char **envp)
 
 opt_found:
 	if (want_device) {
-		devname = *argp++;
+		ctx.devname = *argp++;
 		argc--;
 
-		if (devname == NULL)
+		if (ctx.devname == NULL)
 			exit_bad_args();
-		if (strlen(devname) >= IFNAMSIZ)
+		if (strlen(ctx.devname) >= IFNAMSIZ)
 			exit_bad_args();
 
 		/* Setup our control structures. */
 		memset(&ctx.ifr, 0, sizeof(ctx.ifr));
-		strcpy(ctx.ifr.ifr_name, devname);
+		strcpy(ctx.ifr.ifr_name, ctx.devname);
 
 		/* Open control socket. */
 		ctx.fd = socket(AF_INET, SOCK_DGRAM, 0);
diff --git a/internal.h b/internal.h
index eb13db8..cb126b3 100644
--- a/internal.h
+++ b/internal.h
@@ -90,6 +90,7 @@ static inline int test_bit(unsigned int nr, const unsigned long *addr)
 
 /* Context for sub-commands */
 struct cmd_context {
+	const char *devname;	/* net device name */
 	int fd;			/* socket suitable for ethtool ioctl */
 	struct ifreq ifr;	/* ifreq suitable for ethtool ioctl */
 	int argc;		/* number of arguments to the sub-command */
-- 
1.7.4.4



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
