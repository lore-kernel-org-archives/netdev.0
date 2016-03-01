From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 7/8] net/mlx5e: Support offload cls_flower with
 drop action
Date: Tue, 1 Mar 2016 16:03:18 +0100
Message-ID: <20160301150318.GF2098@nanopsycho.orion>
References: <1456842290-7844-1-git-send-email-amir@vadai.me>
 <1456842290-7844-8-git-send-email-amir@vadai.me>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Or Gerlitz <ogerlitz@mellanox.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>
To: Amir Vadai <amir@vadai.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:36273 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753859AbcCAPDW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 10:03:22 -0500
Received: by mail-wm0-f68.google.com with SMTP id l68so4549885wml.3
        for <netdev@vger.kernel.org>; Tue, 01 Mar 2016 07:03:22 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1456842290-7844-8-git-send-email-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Mar 01, 2016 at 03:24:49PM CET, amir@vadai.me wrote:
>Parse tc_cls_flower_offload into device specific commands and program
>the hardware to classify and act accordingly.
>
>For example, to drop ICMP (ip_proto 1) packets from specific smac, dmac,
>src_ip, src_ip, arriving to interface ens9:
>
> # tc qdisc add dev ens9 ingress
>
> # tc filter add dev ens9 protocol ip parent ffff: \
>     flower ip_proto 1 \
>     dst_mac 7c:fe:90:69:81:62 src_mac 7c:fe:90:69:81:56 \
>     dst_ip 11.11.11.11 src_ip 11.11.11.12 indev ens9 \
>     action drop
>

<snip>

>+static int parse_tc_actions(struct mlx5e_priv *priv, struct tcf_exts *exts,
>+			    u32 *action, u32 *flow_tag)
>+{
>+#ifdef CONFIG_NET_CLS_ACT
>+	const struct tc_action *a;
>+
>+	*flow_tag = MLX5_FS_DEFAULT_FLOW_TAG;
>+	*action = 0;
>+
>+	if (list_empty(&exts->actions))
>+		return -EINVAL;
>+
>+	list_for_each_entry(a, &exts->actions, list) {

I think it would make sense to make this a macro "tc_for_each_action"
and "tc_no_action" for empty list and you can loose ugly
CONFIG_NET_CLS_ACT ifdef
