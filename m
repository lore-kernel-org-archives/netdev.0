From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next PATCH v3 3/8] net: add fdb generic dump routine
Date: Thu, 12 Apr 2012 21:20:09 +0100
Message-ID: <1334262009.2497.20.camel@bwh-desktop.uk.solarflarecom.com>
References: <20120412170258.2717.34628.stgit@jf-dev1-dcblab>
	 <20120412170702.2717.81539.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <shemminger@vyatta.com>, <mst@redhat.com>, <davem@davemloft.net>,
	<sri@us.ibm.com>, <hadi@cyberus.ca>, <jeffrey.t.kirsher@intel.com>,
	<netdev@vger.kernel.org>, <gregory.v.rose@intel.com>,
	<krkumar2@in.ibm.com>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:23242 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S934651Ab2DLUUP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Apr 2012 16:20:15 -0400
In-Reply-To: <20120412170702.2717.81539.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-04-12 at 10:07 -0700, John Fastabend wrote:
> This adds a generic dump routine drivers can call. It
> should be sufficient to handle any bridging model that
> uses the unicast address list. This should be most SR-IOV
> enabled NICs.
> 
> v2: return error on nlmsg_put and use -EMSGSIZE instead
>     of -ENOMEM this is inline other usages

It's still not propagated up to ndo_dflt_fdb_dump() though:

[...]
> +static int nlmsg_populate_fdb(struct sk_buff *skb,
> +			      struct netlink_callback *cb,
> +			      struct net_device *dev,
> +			      int *idx,
> +			      struct netdev_hw_addr_list *list)
> +{
> +	struct netdev_hw_addr *ha;
> +	int err;
> +	u32 pid, seq;
> +
> +	pid = NETLINK_CB(cb->skb).pid;
> +	seq = cb->nlh->nlmsg_seq;
> +
> +	list_for_each_entry(ha, &list->list, list) {
> +		if (*idx < cb->args[0])
> +			goto skip;
> +
> +		err = nlmsg_populate_fdb_fill(skb, dev, ha->addr,
> +					      pid, seq, 0, NTF_SELF);
> +		if (err < 0)
> +			break;
			return err;
> +skip:
> +		*idx += 1;
> +	}
> +	return 0;
> +}
[...]

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
