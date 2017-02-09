From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 1/2] net/devlink: Add E-Switch encapsulation
 control
Date: Thu, 9 Feb 2017 18:10:53 +0100
Message-ID: <20170209171053.GC2018@nanopsycho>
References: <1486657398-6298-1-git-send-email-ogerlitz@mellanox.com>
 <1486657398-6298-2-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Jiri Pirko <jiri@mellanox.com>, netdev@vger.kernel.org,
        Hadar Har-Zion <hadarh@mellanox.com>,
        Roi Dayan <roid@mellanox.com>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:33174 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932148AbdBIRSY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 12:18:24 -0500
Received: by mail-wr0-f196.google.com with SMTP id i10so12613269wrb.0
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 09:18:23 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1486657398-6298-2-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Feb 09, 2017 at 05:23:17PM CET, ogerlitz@mellanox.com wrote:
>From: Roi Dayan <roid@mellanox.com>
>
>This is an e-switch global knob to enable/disable HW support for applying
>encapsulation/decapsulation to VF traffic as part of SRIOV e-switch offloading.
>
>The actual encap/decap is carried out (along with the matching and other actions)
>per offloaded e-switch rules, e.g as done when offloading the TC tunnel key action.
>
>The supported mode are enable/disable.
>
>Signed-off-by: Roi Dayan <roid@mellanox.com>
>Reviewed-by: Or Gerlitz <ogerlitz@mellanox.com>
>---

[...]

>@@ -1470,11 +1480,23 @@ static int devlink_nl_cmd_eswitch_set_doit(struct sk_buff *skb,
> 	const struct devlink_ops *ops = devlink->ops;
> 	u16 mode;
> 	u8 inline_mode;
>+	bool encap;
> 	int err = 0;
> 
> 	if (!ops)
> 		return -EOPNOTSUPP;
> 
>+	if (info->attrs[DEVLINK_ATTR_ESWITCH_ENCAP]) {
>+		if (!ops->eswitch_encap_set)
>+			return -EOPNOTSUPP;
>+		if (!info->attrs[DEVLINK_ATTR_ESWITCH_MODE])
>+			return -EINVAL;
>+		encap = nla_get_u8(info->attrs[DEVLINK_ATTR_ESWITCH_ENCAP]);
>+		err = ops->eswitch_encap_set(devlink, encap);
>+		if (err)
>+			return err;
>+	}

Please maintain the same order as the attr enum and getters and put this
behind the inline_mode. Thanks.
