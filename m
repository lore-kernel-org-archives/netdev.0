From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [v4 PATCH 2/2] NETFILTER userspace part for target HMARK
Date: Fri, 25 Nov 2011 14:20:05 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1111251418440.6279@frira.zrqbmnf.qr>
References: <1322213787-25796-1-git-send-email-hans@schillstrom.com> <1322213787-25796-3-git-send-email-hans@schillstrom.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: kaber@trash.net, pablo@netfilter.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	hans.schillstrom@ericsson.com
To: Hans Schillstrom <hans@schillstrom.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1322213787-25796-3-git-send-email-hans@schillstrom.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Friday 2011-11-25 10:36, Hans Schillstrom wrote:

>+Parameters:
>+For all masks default is all "1:s", to disable a field use mask 0
>+For IPv6 it's just the last 32 bits that is included in the hash

Why limit IPv6 to 32?

>diff --git a/include/linux/netfilter/xt_hmark.h b/include/linux/netfilter/xt_hmark.h
>new file mode 100644
>index 0000000..1760015
>--- /dev/null
>+++ b/include/linux/netfilter/xt_hmark.h
>@@ -0,0 +1,62 @@
>+#ifndef XT_HMARK_H_
>+#define XT_HMARK_H_
>+
>+#include <linux/types.h>
>+
>+/*
>+ * Flags must not start at 0, since it's used as none.
>+ */
>+enum {
>+	XT_HMARK_USE_SNAT = 1,	/* SNAT & DNAT are used by the kernel module */
>+	XT_HMARK_USE_DNAT,
>+	XT_HMARK_SADR_AND,
>+	XT_HMARK_DADR_AND,
>+	XT_HMARK_SPI_AND,
>+	XT_HMARK_SPI_OR,
>+	XT_HMARK_SPORT_AND,
>+	XT_HMARK_DPORT_AND,
>+	XT_HMARK_SPORT_OR,
>+	XT_HMARK_DPORT_OR,
>+	XT_HMARK_PROTO_AND,
>+	XT_HMARK_RND,
>+	XT_HMARK_MODULUS,
>+	XT_HMARK_OFFSET,
>+	XT_F_HMARK_USE_SNAT = 1 << XT_HMARK_USE_SNAT,

This file does not match the kernel-side xt_hmark.h.
Definitions only used within the userspace side should go into libxt_hmark.c
anyhow.

>+union ports {
>+	struct {
>+		__u16	src;
>+		__u16	dst;
>+	} p16;
>+	__u32	v32;
>+};

Bad name "ports", big clash potential.
