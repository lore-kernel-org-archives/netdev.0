From: Or Gerlitz <gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v4 for-next 00/12] Add network namespace support in the RDMA-CM
Date: Wed, 3 Jun 2015 23:07:37 +0300
Message-ID: <CAJ3xEMiO+hEzOJ2oJ5G-mmBeaX4ZHvUyhNSAzsrRDui6dFjvCg@mail.gmail.com>
References: <55671309.6080303@mellanox.com>
	<1432822057.114391.26.camel@redhat.com>
	<55674077.5040707@mellanox.com>
	<20150528174337.GA10448@obsidianresearch.com>
	<1432837360.114391.35.camel@redhat.com>
	<CAJ3xEMh2T5-56rFxWVdct2uAZYW1ZrKivWfS45V-mvhAfwyGaA@mail.gmail.com>
	<1432850150.114391.56.camel@redhat.com>
	<556ED0D5.8010502@mellanox.com>
	<20150603161447.GC12073@obsidianresearch.com>
	<CAJ3xEMjM53sYuEgQV3WPaN4WErk_YcojPY2zBcmq-+3W2dfD+A@mail.gmail.com>
	<20150603195325.GC7902@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150603195325.GC7902-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 3, 2015 at 10:53 PM, Jason Gunthorpe
<jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org> wrote:
> On Wed, Jun 03, 2015 at 10:05:34PM +0300, Or Gerlitz wrote:
>
>> Indeed the DHCP story isn't working there and to get DHCP work
>> something has to be done. But this issue can't serve for blocking the
>> existing UAPI and introduce regression to working systems.
>
> It is not DHCP that concerns me, it is the fact we can't combine net
> namespaces, RDMA-CM and duplicate GUID IPoIB children together without
> adding hacks to the kernel. Searching netdevs by IP is a hack.
>
> I'm mostly fine with it as an optional capability, similar to macvlan,
> I just don't see how to cleanly integrate it with RDMA CM and
> namespaces. And I don't see what RDMA CM is supposed to do when
> it hits this case.
>
> So, any ideas that don't involve the searching for IP hack??
>
> [And yes, as discussed with Haggie, it is not the worst hack in the
>  world, and maybe we can live with it, but lets understand the trade
>  offs carefully]

As Haggai wrote, if we let the using IP address thing to fly up, we have
support for RDMA in containers using the RDMA-CM at IPoIB environments.
This will let people test, use, experiment, fix, interact (and even
production-it when static IP address assignment scheme is used).

Later, usage of alias GUIDs for IPoIB RTNL childs would allow to
remove the IP thing.

Later, the next stage/s in Matan's work on the RoCE GID table would
allow to support MACVLAN and hence RoCE too.

This is how the Linux kernel being evolved since the 2.5 failure to
come up with giant releases -- doing things in relativity small steps.


> Also, now that this has been brought up, I think you need to make a
> patch to fix the IPv6 SLAAC breakage this caused. It looks trivial to
> modify addrconf_ifid_infiniband to return error if the IPoIB child is
> sharing a guid. It was not good at all to push the child patches
> forward to 3.6/3.7 if you knew that IPv6 SLAAC was broken by them.

Till the alias GUID thing is introduced, maybe we can patch
addrconf_ifid_infiniband to use the QPN value from the device HW
address to come up with unique IPv6 link local address, agree? where
you think we can place the 24 bits QPN?

Or.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
