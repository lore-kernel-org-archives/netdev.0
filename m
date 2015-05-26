From: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Subject: Re: [PATCH v4 for-next 00/12] Add network namespace support in the
 RDMA-CM
Date: Tue, 26 May 2015 10:59:28 -0600
Message-ID: <20150526165928.GC11800@obsidianresearch.com>
References: <1431841868-28063-1-git-send-email-haggaie@mellanox.com>
 <1432647280.28905.107.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1432647280.28905.107.camel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, May 26, 2015 at 09:34:40AM -0400, Doug Ledford wrote:

> This is a core feature more than anything else.  Namespaces for RDMA
> devices is not unique to IB or RoCE in any way.  Yet no thought has been
> given to how this will work universally across all of the RDMA
> capable

I think if Haggi is able to follow the perscription I gave then things
will be general.

 - All rdma cm ids are associated with a netdev
 - The output flow uses that netdev to restrict, configure and
   determine the output RDMA device QP
 - The input flow locates the netdev as step one and then uses the
   (netdev,ip,port) tuple to find the rdma listener, which is in turn
   tied to a netdev and is restricted/configured by it.

The technology specific part is the two maps: from (input
device,packet) to netdev, from netdev to (output device,packet)

After the above clean up is done, namespace enabling is basically
providing those two mapping functions for each technology in a way
that can locate delegatable netdevs.

The trivial case for all the ethernet techs is to provide the above
maps that can take the (input device,VLAN) and locate the correct
child VLAN specific netdev. The existing code to support VLAN should
pretty much immediately enable basic namespace support for all the
ethernet families.

The big open question for ethernet is how to work without relying on
VLAN to create delgated netdevs - typically one would use a bridge and
veth's, which do not seem very RDMA compatible. But that doesn't need
to be answered right now.

Remember, this isn't RDMA namespaces, this is netdev namespace support
for RDMA-CM -> very different things.

Basically, I'm happy with the generality story, if the clean up work I
outlined turns out..

> issue for usNIC as if you want namespace support there, you just start
> the user space app in a given namespace and you are probably 90% of
> the

usNIC has no kernel facing functionality, and no interaction with
RDMA-CM, so it is irrelevant to any discussion about RDMA-CM :(

Jason
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
