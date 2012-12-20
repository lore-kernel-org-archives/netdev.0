From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH net-next V4 02/13] bridge: Add vlan filtering
 infrastructure
Date: Thu, 20 Dec 2012 15:39:13 +0200
Message-ID: <20121220153913.11a10fd0@pixies.home.jungo.com>
References: <1355939304-21804-1-git-send-email-vyasevic@redhat.com>
	<1355939304-21804-3-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com, davem@davemloft.net,
	or.gerlitz@gmail.com, jhs@mojatatu.com, mst@redhat.com,
	erdnetdev@gmail.com, jiri@resnulli.us
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:55809 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751744Ab2LTNjU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2012 08:39:20 -0500
Received: by mail-wi0-f178.google.com with SMTP id hn3so1983605wib.17
        for <netdev@vger.kernel.org>; Thu, 20 Dec 2012 05:39:18 -0800 (PST)
In-Reply-To: <1355939304-21804-3-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Vlad,

On Wed, 19 Dec 2012 12:48:13 -0500 Vlad Yasevich <vyasevic@redhat.com> wrote:
> +static void nbp_vlan_flush(struct net_bridge_port *p)
> +{
> +	struct net_port_vlan *pve;
> +	struct net_port_vlan *tmp;
> +
> +	ASSERT_RTNL();
> +
> +	list_for_each_entry_safe(pve, tmp, &p->vlan_list, list)
> +		nbp_vlan_delete(p, pve->vid, BRIDGE_FLAGS_SELF);

Why would you want to clear "bridge master port" association from this
vlan, in the event of NBP destruction?
The "bridge port" may still be a member of this vlan, doesn't it?
Seems flags argument should be 0.

> +#define BR_VID_HASH_SIZE (1<<6)
> +#define br_vlan_hash(vid) ((vid) % (BR_VID_HASH_SIZE - 1))

Did you mean:                       & (BR_VID_HASH_SIZE - 1)

Regards,
Shmulik
