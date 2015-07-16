From: Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: RE: [PATCH v1 08/12] IB/cma: Add net_dev and private data checks to
 RDMA CM
Date: Thu, 16 Jul 2015 12:01:55 +0000
Message-ID: <HE1PR05MB1418FA1E41CFA446C04FC07FB1990@HE1PR05MB1418.eurprd05.prod.outlook.com>
References: <1434976961-27424-1-git-send-email-haggaie@mellanox.com>
 <1434976961-27424-9-git-send-email-haggaie@mellanox.com>
 <20150713181414.GJ23832@obsidianresearch.com> <55A63CAC.60603@mellanox.com>
 <20150715184934.GD23588@obsidianresearch.com>
 <HE1PR05MB1418C82958B3CCF0D3531E5BB19A0@HE1PR05MB1418.eurprd05.prod.outlook.com>
 <20150715210342.GA32516@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150715210342.GA32516-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> From: Jason Gunthorpe [mailto:jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org]

> > After all, it is the payload that designates the entity that you
> > want to establish a connection to, rather than the packet headers,
> > which are just meant to relay the packet to the proper CM
> 
> No, that isn't right. The IBA uses the GMP's destination first, then
> serviceID as the demux. Services IDs are not globally unique, they are
> scoped by the destination.
> 

The destination is the physical CA port and kernel CM agent, so I don't think the answer is that clear.
Going forward along these lines:
- Name space lookup is done based on BTH.pkey, private_data.IP, and optionally GRH.DGID (if present, for extra validation)
-- Primary and alternate paths are not considered at all

- If P_Key enforcement is set up via cgroups:
-- For CM processing, we only check BTH.pkey
--- Upon conflict, the packet is dropped
-- The primary/alternate path pkeys are not validated by CM, but will be validated during QP modification

Does this sound OK?

In any case, let's complete the namespace lookup first, and then follow up with a cgroup patchset.

> The path data is just *routing* it doesn't describe at all the entity
> we want to talk to, it is only a proposal for how to flow data to it.
> 
> In any event, both the GMP headers and the path data needs to be
> checked against the container's pkey list. I don't know why this is so
> contentions.
> 
> Jason
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
