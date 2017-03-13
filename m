From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] VLAN, support ingress/egress priority map flushing
Date: Mon, 13 Mar 2017 08:28:38 -0700
Message-ID: <1489418918.28631.82.camel@edumazet-glaptop3.roam.corp.google.com>
References: <f07d2296-31e0-30b1-c798-f5f1d87d573a@dtsystems.be>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ben Greear <greearb@candelatech.com>
To: Thierry Du Tre <thierry@dtsystems.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33028 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750812AbdCMP2l (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 11:28:41 -0400
Received: by mail-pf0-f195.google.com with SMTP id v190so19357513pfb.0
        for <netdev@vger.kernel.org>; Mon, 13 Mar 2017 08:28:40 -0700 (PDT)
In-Reply-To: <f07d2296-31e0-30b1-c798-f5f1d87d573a@dtsystems.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-03-13 at 15:36 +0100, Thierry Du Tre wrote:

> +void vlan_dev_flush_egress_priority(const struct net_device *dev)
> +{
> +	struct vlan_dev_priv *vlan = vlan_dev_priv(dev);
> +	struct vlan_priority_tci_mapping *mp;
> +	int i;
> +
> +	for (i = 0; i < ARRAY_SIZE(vlan->egress_priority_map); i++) {
> +		while ((mp = vlan->egress_priority_map[i]) != NULL) {
> +			vlan->egress_priority_map[i] = mp->next;
> +			kfree(mp);
> +		}
> +	}
> +	vlan->nr_egress_mappings = 0;
> +}


Are you doing this on a live device ?

Looks you'll need proper RCU support then.

Otherwise, crashes will happen, say in egress_priority_map()

smp_rmb() wont be enough if items can now be destroyed.
