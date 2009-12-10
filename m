From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/1] cxgb3i: Fix a login over vlan issue
Date: Thu, 10 Dec 2009 12:49:48 +0100
Message-ID: <4B20E05C.1010604@trash.net>
References: <200912100535.nBA5ZM0L000413@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: linux-scsi@vger.kernel.org, open-iscsi@googlegroups.com,
	netdev@vger.kernel.org, davem@davemloft.net, rakesh@chelsio.com,
	James.Bottomley@HansenPartnership.com, michaelc@cs.wisc.edu,
	linux-kernel@vger.kernel.org
To: kxie@chelsio.com
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <200912100535.nBA5ZM0L000413@localhost.localdomain>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

kxie@chelsio.com wrote:
> [PATCH 1/1] cxgb3i: Fix a login over vlan issue
> 
> From: Karen Xie <kxie@chelsio.com>
> 
> Fix a login over vlan issue, when parent interface is vlan and we are using
> 
> cxgb3i sepecific private ip address in '/etc/iscsi/ifaces/' iface file.
> 
> +/**
> + * cxgb3i_find_dev - find the interface associated with the given address
> + * @ipaddr: ip address
> + */
> +static struct net_device *cxgb3i_find_dev(__be32 ipaddr)
> +{
> +	struct flowi fl;
> +	int err;
> +	struct rtable *rt;
> +
> +	memset(&fl, 0, sizeof(fl));
> +	fl.nl_u.ip4_u.daddr = ipaddr;
> +
> +	err = ip_route_output_key(&init_net, &rt, &fl);
> +	if (!err)
> +		return (&rt->u.dst)->dev;
> +
> +	return NULL;
> +}

This probably shouldn't be using init_net but the current namespace.
