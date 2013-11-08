From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCH net 1/2] macvlan: introduce IFF_MACVLAN flag and helper
 functions
Date: Fri, 8 Nov 2013 16:23:55 +0100
Message-ID: <20131108152355.GA13952@unicorn.suse.cz>
References: <cover.1383915401.git.mkubecek@suse.cz>
 <7ca53d743ffa48f671c35335473798c66d908d56.1383915401.git.mkubecek@suse.cz>
 <527CFDE7.4040405@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:50358 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756972Ab3KHPX5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Nov 2013 10:23:57 -0500
Content-Disposition: inline
In-Reply-To: <527CFDE7.4040405@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 08, 2013 at 07:06:15AM -0800, John Fastabend wrote:
> 
> I just added this to netdevice.h here,
> 
> +static inline bool netif_is_macvlan(struct net_device *dev)
> +{
> +	return dev->priv_flags & IFF_MACVLAN;
> +}
> +
> 
> although I didn't wrap it in the IS_ENABLED if/else, but a
> bitmask in slow path probably doesn't matter. As a precedent
> none of the other netif_is_* bitmasks are wrapped like this.
> 
> The patch is
> 
> commit 2a47fa45d4dfbc54659d28de311a1f764b296a3c
> Author: John Fastabend <john.r.fastabend@intel.com>
> Date:   Wed Nov 6 09:54:52 2013 -0800
> 
>     ixgbe: enable l2 forwarding acceleration for macvlans
> 
> 
> I think you need to respin the patch with just the
> macvlan_dev_real_dev() part.

My patch also conflicts with

  a6cc0cfa  net: Add layer 2 hardware acceleration operations for macvlan devices

which introduced the IFF_MACVLAN flags (but sets it in
macvlan_common_newlink()). Both of yours are in net-next while mine are
against net (as 2/2 is a bugfix) which is why I didn't notice them.
I'm not sure what to do in such case.

                                                         Michal Kubecek
