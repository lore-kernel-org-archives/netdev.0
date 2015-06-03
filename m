From: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Subject: Re: [PATCH v4 for-next 00/12] Add network namespace support in the
 RDMA-CM
Date: Wed, 3 Jun 2015 15:45:08 -0600
Message-ID: <20150603214508.GA14968@obsidianresearch.com>
References: <55674077.5040707@mellanox.com>
 <20150528174337.GA10448@obsidianresearch.com>
 <1432837360.114391.35.camel@redhat.com>
 <CAJ3xEMh2T5-56rFxWVdct2uAZYW1ZrKivWfS45V-mvhAfwyGaA@mail.gmail.com>
 <1432850150.114391.56.camel@redhat.com>
 <556ED0D5.8010502@mellanox.com>
 <20150603161447.GC12073@obsidianresearch.com>
 <CAJ3xEMjM53sYuEgQV3WPaN4WErk_YcojPY2zBcmq-+3W2dfD+A@mail.gmail.com>
 <20150603195325.GC7902@obsidianresearch.com>
 <CAJ3xEMiO+hEzOJ2oJ5G-mmBeaX4ZHvUyhNSAzsrRDui6dFjvCg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Or Gerlitz <gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAJ3xEMiO+hEzOJ2oJ5G-mmBeaX4ZHvUyhNSAzsrRDui6dFjvCg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 03, 2015 at 11:07:37PM +0300, Or Gerlitz wrote:
> As Haggai wrote, if we let the using IP address thing to fly up, we have
> support for RDMA in containers using the RDMA-CM at IPoIB environments.
> This will let people test, use, experiment, fix, interact (and even
> production-it when static IP address assignment scheme is used).

Sure, I think we all understand the goal, and you've explained some
reasonable use cases for the child support.

> Later, usage of alias GUIDs for IPoIB RTNL childs would allow to
> remove the IP thing.

How do we remove it? Along with same-guid child support? What is your
idea here?

> > Also, now that this has been brought up, I think you need to make a
> > patch to fix the IPv6 SLAAC breakage this caused. It looks trivial to
> > modify addrconf_ifid_infiniband to return error if the IPoIB child is
> > sharing a guid. It was not good at all to push the child patches
> > forward to 3.6/3.7 if you knew that IPv6 SLAAC was broken by them.
> 
> Till the alias GUID thing is introduced, maybe we can patch
> addrconf_ifid_infiniband to use the QPN value from the device HW
> address to come up with unique IPv6 link local address, agree? where
> you think we can place the 24 bits QPN?

I don't know if that is a good idea, an unstable SLAAC is not in
spirit with the RFCs. The safest bet is to return error and disable
SLAAC completely.

But I'm just guessing here - I'm only feel strongly that something
should be done to address this issue in the existing kernel.

Jason
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
