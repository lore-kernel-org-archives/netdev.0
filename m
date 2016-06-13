From: Hannes Frederic Sowa <hannes@redhat.com>
Subject: Re: [net-next PATCH 02/15] net: Merge VXLAN and GENEVE push notifiers
 into a single notifier
Date: Mon, 13 Jun 2016 19:57:31 +0200
Message-ID: <77eb25b2-d775-ec6f-c945-524d73113c96@redhat.com>
References: <20160613173750.15186.24381.stgit@localhost.localdomain>
 <20160613174806.15186.64702.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: jesse@kernel.org, jbenc@redhat.com, alexander.duyck@gmail.com,
	saeedm@mellanox.com, ariel.elior@qlogic.com, tom@herbertland.com,
	Dept-GELinuxNICDev@qlogic.com, davem@davemloft.net,
	eugenia@mellanox.com
To: Alexander Duyck <aduyck@mirantis.com>, netdev@vger.kernel.org,
	intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53647 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161158AbcFMR5n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Jun 2016 13:57:43 -0400
In-Reply-To: <20160613174806.15186.64702.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Alex,

very cool series!

On 13.06.2016 19:48, Alexander Duyck wrote:
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index d101e4d904ba..e959b6348f91 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -1269,6 +1269,14 @@ struct net_device_ops {
>  	void			(*ndo_del_geneve_port)(struct  net_device *dev,
>  						       sa_family_t sa_family,
>  						       __be16 port);
> +	void			(*ndo_add_udp_enc_port)(struct  net_device *dev,
> +						       sa_family_t sa_family,
> +						       __be16 port,
> +						       unsigned int type);
> +	void			(*ndo_del_udp_enc_port)(struct  net_device *dev,
> +						       sa_family_t sa_family,
> +						       __be16 port,
> +						       unsigned int type);
>  	void*			(*ndo_dfwd_add_station)(struct net_device *pdev,
>  							struct net_device *dev);
>  	void			(*ndo_dfwd_del_station)(struct net_device *pdev,

What do you think about adding a struct as argument to
ndo_*_udp_enc_port? As a result we can much easier add new fields in
case future NICs allow us to e.g. specify a bound ip address?

Thanks,
Hannes
