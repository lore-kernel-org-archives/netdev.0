From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 1/2] net: move is_vlan_dev into public header file (v2)
Date: Tue, 24 May 2011 11:36:35 -0700
Message-ID: <1306262195.2298.46.camel@Joe-Laptop>
References: <1306257314-3925-1-git-send-email-nhorman@tuxdriver.com>
	 <1306261869-7276-1-git-send-email-nhorman@tuxdriver.com>
	 <1306261869-7276-2-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	bhutchings@solarflare.com
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1967 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932161Ab1EXSgg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 May 2011 14:36:36 -0400
In-Reply-To: <1306261869-7276-2-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-05-24 at 14:31 -0400, Neil Horman wrote:
> Migrate is_vlan_dev() to if_vlan.h so that core networkig can use it
[]
> diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
[]
> @@ -110,6 +110,11 @@ static inline void vlan_group_set_device(struct vlan_group *vg,
>  	array[vlan_id % VLAN_GROUP_ARRAY_PART_LEN] = dev;
>  }
>  
> +static inline int is_vlan_dev(struct net_device *dev)
> +{
> +        return dev->priv_flags & IFF_802_1Q_VLAN;
> +}

perhaps:

static bool is_vlan_dev(const struct net_device *dev)
{
	return !!(dev->priv_flags & IFF_802_1Q_VLAN);
}


