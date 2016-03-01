From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 8/8] net/mlx5e: Support offload cls_flower with
 sskbedit mark action
Date: Tue, 1 Mar 2016 15:58:10 +0100
Message-ID: <20160301145810.GE2098@nanopsycho.orion>
References: <1456842290-7844-1-git-send-email-amir@vadai.me>
 <1456842290-7844-9-git-send-email-amir@vadai.me>
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
Received: from mail-wm0-f68.google.com ([74.125.82.68]:32787 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753885AbcCAO6N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 09:58:13 -0500
Received: by mail-wm0-f68.google.com with SMTP id n186so4553876wmn.0
        for <netdev@vger.kernel.org>; Tue, 01 Mar 2016 06:58:13 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1456842290-7844-9-git-send-email-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Mar 01, 2016 at 03:24:50PM CET, amir@vadai.me wrote:
>Introduce offloading of skbedit mark action.
>
>For example, to mark with 0x1234, all TCP (ip_proto 6) packets arriving
>to interface ens9:
>
> # tc qdisc add dev ens9 ingress
> # tc filter add dev ens9 protocol ip parent ffff: \
>     flower ip_proto 6 \
>     indev ens9 \
>     action skbedit mark 0x1234
>

<snip>

>@@ -287,6 +288,21 @@ static int parse_tc_actions(struct mlx5e_priv *priv, struct tcf_exts *exts,
> 			continue;
> 		}
> 
>+		if (is_tcf_skbedit_mark(a)) {
>+			u32 mark = tcf_skbedit_mark(a);
>+
>+			if (mark & ~MLX5E_TC_FLOW_ID_MASK) {
>+				netdev_warn(priv->netdev,
>+					    "Bad flow mark - only 16 bit is supported: 0x%x\n",

You can start printk string on the first line.
