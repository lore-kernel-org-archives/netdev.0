From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: [PATCH iptables] libxt_cgroup2: add support for cgroup2 path
 matching
Date: Wed, 18 Nov 2015 00:02:01 +0100 (CET)
Message-ID: <alpine.LSU.2.20.1511172356570.13966@nerf40.vanv.qr>
References: <1447789240-29394-1-git-send-email-tj@kernel.org> <20151117194221.GB22864@mtj.duckdns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: davem@davemloft.net, pablo@netfilter.org, kaber@trash.net,
	kadlec@blackhole.kfki.hu, lizefan@huawei.com, hannes@cmpxchg.org,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org, cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-team@fb.com,
	daniel@iogearbox.net, daniel.wagner@bmw-carit.de,
	nhorman@tuxdriver.com
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151117194221.GB22864@mtj.duckdns.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Tuesday 2015-11-17 20:42, Tejun Heo wrote:
>+static void cgroup2_save(const void *ip, const struct xt_entry_match *match)
>+{
>+	const struct xt_cgroup2_info *info = (void *)match->data;
>+
>+	printf("%s --path %s", info->invert ? " !" : "", info->path);
>+}

Can cgroup path names contain anything fancy, like spaces, backslashes, etc.?
If so, xtables_save_string() will be needed here.

>+static struct xtables_match cgroup2_match = {
>+	.family		= NFPROTO_UNSPEC,
>+	.name		= "cgroup2",
>+	.version	= XTABLES_VERSION,
>+	.size		= XT_ALIGN(sizeof(struct xt_cgroup2_info)),
>+	.userspacesize	= XT_ALIGN(sizeof(struct xt_cgroup2_info)),

userspacesize must not include xt_cgroup2_info.priv.
Change to offsetof(...), cf. other .c modules which do this.


>+++ b/extensions/libxt_cgroup2.man
>@@ -0,0 +1,24 @@
>+.TP
>+[\fB!\fP] \fB\-\-path\fP \fIpath\fP
>+Match cgroup2 membership.
>+
>+Each socket is associated with the v2 cgroup of the creating process.
>+This matches packets coming from or going to all sockets in the
>+sub-hierarchy of the specified path.  The path should be relative to
>+the root of the cgroup2 hierarchy.  Can be used in the OUTPUT and
>+INPUT chains to assign particular firewall policies for aggregated
>+processes on the system. This allows for more fine-grained firewall
>+policies that only match for a subset of the system's processes.
>+
>+\fBIMPORTANT\fP: when being used in the INPUT chain, the cgroup2
>+matcher is currently only of limited functionality, meaning it
>+will only match on packets that are processed for local sockets
>+through early socket demuxing. Therefore, general usage on the
>+INPUT chain is disadviced unless the implications are well

is disadviced (sic)  -> is not advised
