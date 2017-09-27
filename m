From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 1/6] net: dsa: Fix SWITCHDEV_ATTR_ID_PORT_PARENT_ID
Date: Wed, 27 Sep 2017 11:31:54 -0400
Message-ID: <87tvzow42d.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <1506464764-12699-1-git-send-email-andrew@lunn.ch> <1506464764-12699-2-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:56478 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752279AbdI0Pfe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2017 11:35:34 -0400
In-Reply-To: <1506464764-12699-2-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> @@ -354,13 +354,16 @@ static int dsa_slave_port_attr_get(struct net_device *dev,
>  				   struct switchdev_attr *attr)
>  {
>  	struct dsa_slave_priv *p = netdev_priv(dev);
> -	struct dsa_switch *ds = p->dp->ds;
>  
>  	switch (attr->id) {
> -	case SWITCHDEV_ATTR_ID_PORT_PARENT_ID:
> -		attr->u.ppid.id_len = sizeof(ds->index);
> -		memcpy(&attr->u.ppid.id, &ds->index, attr->u.ppid.id_len);
> +	case SWITCHDEV_ATTR_ID_PORT_PARENT_ID: {
> +		struct dsa_switch *ds = p->dp->ds;
> +		struct dsa_switch_tree *dst = ds->dst;
> +
> +		attr->u.ppid.id_len = sizeof(dst->tree);
> +		memcpy(&attr->u.ppid.id, &dst->tree, sizeof(dst->tree));
>  		break;
> +	}
>  	case SWITCHDEV_ATTR_ID_PORT_BRIDGE_FLAGS_SUPPORT:
>  		attr->u.brport_flags_support = 0;
>  		break;

I am pretty sure the kernel folks won't like blocks within case
statments. Simply declare dst = p->dp->ds->dst at the beginning.

Also keeping attr->u.ppid.id_len as memcpy's third argument like other
switchdev users do would be prefered.

Otherwise using the tree index is indeed the way to go:

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>


Thanks,

        Vivien
