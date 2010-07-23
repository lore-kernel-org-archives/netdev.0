From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH iptables] extension: add xt_cpu match
Date: Fri, 23 Jul 2010 18:46:41 +0200 (CEST)
Message-ID: <alpine.LSU.2.01.1007231841500.2880@obet.zrqbmnf.qr>
References: <1279807385.2467.67.camel@edumazet-laptop>  <alpine.LSU.2.01.1007221611510.1619@obet.zrqbmnf.qr>  <1279811939.2467.79.camel@edumazet-laptop>  <4C497644.7050201@trash.net> <1279892621.2481.53.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Patrick McHardy <kaber@trash.net>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:44926 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752727Ab0GWQqm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Jul 2010 12:46:42 -0400
In-Reply-To: <1279892621.2481.53.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Friday 2010-07-23 15:43, Eric Dumazet wrote:
>+
>+static const struct option cpu_opts[] = {
>+	{ "cpu", 1, NULL, '1' },
>+	{ .name = NULL }
>+};

I will never understand that sort of style mix logic. Why the
C99 initializer only on the sentinel?

{
	{.name = "cpu", .has_arg = true, .val = '1'},
	{NULL},
};

>+cpu_print(const void *ip, const struct xt_entry_match *match, int numeric)
>+{
>+	const struct xt_cpu_info *info = (void *)match->data;
>+
>+	printf("cpu %s%u ", info->invert ? "! ":"", info->cpu);
>+}
>+
>+static void cpu_save(const void *ip, const struct xt_entry_match *match)
>+{
>+	const struct xt_cpu_info *info = (void *)match->data;
>+
>+	printf("%s--cpu %u ", info->invert ? "! ":"", info->cpu);
>+}

Using if (info->invert) would save the empty string.

>diff --git a/extensions/libxt_cpu.man b/extensions/libxt_cpu.man
>index e69de29..f42ac7a 100644
>--- a/extensions/libxt_cpu.man
>+++ b/extensions/libxt_cpu.man
>@@ -0,0 +1,16 @@
>+.TP
>+[\fB!\fP] \fB\-\-cpu\fP \fInumber\fP
>+
>+Match cpu handling this packet. cpus are numbered from 0 to NR_CPUS-1

Unwanted blank line.

>+Can be used in combination with RPS (Remote Packet Steering) or
>+multiqueue NICS to spread network traffic on different queues.
>+.PP
>+Example:
>+.PP
>+iptables \-t nat \-A PREROUTING \-p tcp \-\-dport 80 \-m cpu \-\-cpu 0 
>+        \-j REDIRECT \-\-to\-port 8080

Unwanted indent.

>+.PP
>+iptables \-t nat \-A PREROUTING \-p tcp \-\-dport 80 \-m cpu \-\-cpu 1 
>+        \-j REDIRECT \-\-to\-port 8081
>+.PP
>+Available since linux 2.6.36

Linux.
