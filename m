From: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Subject: Re: [PATCH v1 08/12] IB/cma: Add net_dev and private data checks to
 RDMA CM
Date: Wed, 15 Jul 2015 15:03:42 -0600
Message-ID: <20150715210342.GA32516@obsidianresearch.com>
References: <1434976961-27424-1-git-send-email-haggaie@mellanox.com>
 <1434976961-27424-9-git-send-email-haggaie@mellanox.com>
 <20150713181414.GJ23832@obsidianresearch.com>
 <55A63CAC.60603@mellanox.com>
 <20150715184934.GD23588@obsidianresearch.com>
 <HE1PR05MB1418C82958B3CCF0D3531E5BB19A0@HE1PR05MB1418.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <HE1PR05MB1418C82958B3CCF0D3531E5BB19A0-eBadYZ65MZ87O8BmmlM1zNqRiQSDpxhJvxpqHgZTriW3zl9H0oFU5g@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 15, 2015 at 08:27:06PM +0000, Liran Liss wrote:
> If you want to restrict a container to a specific set of pkeys, use
> cgroups.

Ideally yes, but in the absence of a cgroup the set of pkeys assigned
to the container via ipoib is a reasonable alternate.

> This would apply both to CM MADs and QPs.
> - In the MAD case, CM MADs would be first matched to a namespace and rdma_id and dropped upon pkey conflict (with either the headers or the payload).
> - In the QP case, modify_qp() would fail on conflict.
> Partitioning needs to be enforced also for applications that don't use the CM at all...

Yep, that is how pkey checking should work, cgroup or not.

So, you agree with me.

I say that until we get a cgroup capability, the pkey list of the
container is the set of IPoIB interfaces associated with it, and we
still have to do the various checks above. The first check is relavent
to this patchset and should be done by using the GMP's headers to
locate the net device.

> For namespaces, it seems more natural to lookup the namespace based
> solely on the CM payload.

How so? Which payload content do you use? The primary path? The
alternate path?

> After all, it is the payload that designates the entity that you
> want to establish a connection to, rather than the packet headers,
> which are just meant to relay the packet to the proper CM

No, that isn't right. The IBA uses the GMP's destination first, then
serviceID as the demux. Services IDs are not globally unique, they are
scoped by the destination.

The path data is just *routing* it doesn't describe at all the entity
we want to talk to, it is only a proposal for how to flow data to it.

In any event, both the GMP headers and the path data needs to be
checked against the container's pkey list. I don't know why this is so
contentions.

Jason
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
