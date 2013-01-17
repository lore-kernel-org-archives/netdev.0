From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next V6 12/14] bridge: Add vlan support to static
 neighbors
Date: Thu, 17 Jan 2013 05:16:02 +0000 (UTC)
Message-ID: <kd81eh$ptv$3@ger.gmane.org>
References: <1358360289-23249-1-git-send-email-vyasevic@redhat.com>
 <1358360289-23249-13-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:43262 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758296Ab3AQFQX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jan 2013 00:16:23 -0500
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1Tvhq4-0002FE-Uq
	for netdev@vger.kernel.org; Thu, 17 Jan 2013 06:16:32 +0100
Received: from 222.221.64.75 ([222.221.64.75])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 17 Jan 2013 06:16:32 +0100
Received: from xiyou.wangcong by 222.221.64.75 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 17 Jan 2013 06:16:32 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 16 Jan 2013 at 18:18 GMT, Vlad Yasevich <vyasevic@redhat.com> wrote:
> diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
> index a244efc..90d0bc9 100644
> --- a/net/bridge/br_fdb.c
> +++ b/net/bridge/br_fdb.c
> @@ -506,6 +506,10 @@ static int fdb_fill_info(struct sk_buff *skb, const struct net_bridge *br,
>  	ci.ndm_refcnt	 = 0;
>  	if (nla_put(skb, NDA_CACHEINFO, sizeof(ci), &ci))
>  		goto nla_put_failure;
> +
> +	if (nla_put(skb, NDA_VLAN, sizeof(u16), &fdb->vlan_id))
> +		goto nla_put_failure;

Why not just nla_put_u16()?


> +
> +		/* We have vlans configured on this port and user didn't
> +		 * specify a VLAN.  To be nice, add/update entry for every
> +		 * vlan on this port.
> +		 */
> +		err = -ENOENT;
> +		list_for_each_entry_rcu(pve, &p->vlan_info.vlan_list, list) {
> +			err &= __br_fdb_delete(p, addr, pve->vid);
> +		}

 '&=' or '|='?
