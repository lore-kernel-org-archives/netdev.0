From: Eric Dumazet <erdnetdev@gmail.com>
Subject: Re: [PATCH V2 01/12] bridge: Add vlan filtering infrastructure
Date: Tue, 18 Dec 2012 13:13:51 -0800
Message-ID: <1355865231.9380.119.camel@edumazet-glaptop>
References: <1355857263-31197-1-git-send-email-vyasevic@redhat.com>
	 <1355857263-31197-2-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com, davem@davemloft.net,
	or.gerlitz@gmail.com, jhs@mojatatu.com, mst@redhat.com
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f43.google.com ([209.85.210.43]:43472 "EHLO
	mail-da0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751348Ab2LRVNy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2012 16:13:54 -0500
Received: by mail-da0-f43.google.com with SMTP id u36so539553dak.30
        for <netdev@vger.kernel.org>; Tue, 18 Dec 2012 13:13:54 -0800 (PST)
In-Reply-To: <1355857263-31197-2-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-12-18 at 14:00 -0500, Vlad Yasevich wrote:

> +static void br_vlan_destroy(struct net_bridge_vlan *vlan)
> +{
> +	if (!bitmap_empty(vlan->port_bitmap, PORT_BITMAP_LEN)) {
> +		pr_err("Attempt to delete a VLAN %d from the bridge with "
> +		       "non-empty port bitmap (%p)\n", vlan->vid, vlan);
> +		BUG();
> +	}
> +
> +	hlist_del_rcu(&vlan->hlist);
> +	synchronize_net();
> +	kfree_rcu(vlan, rcu);
> +}

Not clear why you both use synchronize_net() and kfree_rcu()
