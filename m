From: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Subject: Re: [PATCH for-next 01/10] net/core: Add support for configuring VF
 GUIDs
Date: Tue, 1 Mar 2016 10:37:51 -0700
Message-ID: <20160301173751.GA25176@obsidianresearch.com>
References: <1456851143-138332-1-git-send-email-eli@mellanox.com>
 <1456851143-138332-2-git-send-email-eli@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1456851143-138332-2-git-send-email-eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 01, 2016 at 06:52:14PM +0200, Eli Cohen wrote:
> Add two new NLAs to support configuration of Infiniband node or port
> GUIDs. New applications can choose to use this interface to configure
> GUIDs with iproute2 with commands such as:
> 
> ip link set dev ib0 vf 0 node_guid 00:02:c9:03:00:21:6e:70
> ip link set dev ib0 vf 0 port_guid 00:02:c9:03:00:21:6e:78

I like this idea better than the last version..

> +static int handle_vf_mac(struct net_device *dev, struct ifla_vf_mac *ivm)
> +{
[..]
> +	return handle_infiniband_guid(dev, &ivt, IFLA_VF_IB_PORT_GUID);

But is this emulation really necessary? It seems dangerous and
continues the bad practice of assuming IFLA_VF_MAC is fixed to 6 bytes
in size, and is not just LLADDR bytes. I'd rather see mac sets fail on
IB.

Jason
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
