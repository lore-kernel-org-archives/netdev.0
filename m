From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 1/2] Add ndo_set_vf_port_profile
Date: Sat, 24 Apr 2010 00:19:34 -0700 (PDT)
Message-ID: <20100424.001934.189691704.davem@davemloft.net>
References: <20100424003540.12745.81403.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, chrisw@redhat.com, arnd@arndb.de
To: scofeldm@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56026
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752125Ab0DXHTa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Apr 2010 03:19:30 -0400
In-Reply-To: <20100424003540.12745.81403.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <scofeldm@cisco.com>
Date: Fri, 23 Apr 2010 17:35:41 -0700

> +
> +struct ifla_vf_port_profile {
> +	__u32 vf;
> +	__u8 port_profile[64];
> +	__u8 mac[32];
> +	__u8 host_uuid[64]; /* e.g. "CEEFD3B1-9E11-11DE-BDFD-000BAB01C0FB" */
> +	__u8 client_uuid[64];
> +	__u8 client_name[64]; /* e.g. "vm0-eth1" */
> +};
> +

Please define some macros to represent the string sizes.

;
>  	int			(*ndo_set_vf_tx_rate)(struct net_device *dev,
>  						      int vf, int rate);
> +	int			(*ndo_set_vf_port_profile)(
> +					struct net_device *dev, int vf,
> +					u8 *port_profile, u8 *mac,
> +					u8 *host_uuid,
> +					u8 *client_uuid,
> +					u8 *client_name);
>  	int			(*ndo_get_vf_config)(struct net_device *dev,

Just pass the "struct ifla_vf_port_profile *" instead of tons of
arguments.

Also, I think it's reasonable to fetch the current profile in use, so
GETLINK ought to report these things.  To make it generic we can
maintain the settings given to us in software, hung off of the netdev
struct, and simply report that during GETLINK.

In fact, in general, anything that can be "set" should always be
available from a "get".
