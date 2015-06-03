From: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Subject: Re: [PATCH v4 for-next 00/12] Add network namespace support in the
 RDMA-CM
Date: Wed, 3 Jun 2015 17:48:11 -0600
Message-ID: <20150603234811.GA15128@obsidianresearch.com>
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

> > I'm mostly fine with it as an optional capability, similar to macvlan,
> > I just don't see how to cleanly integrate it with RDMA CM and
> > namespaces. And I don't see what RDMA CM is supposed to do when
> > it hits this case.
> >
> > So, any ideas that don't involve the searching for IP hack??
> >
> > [And yes, as discussed with Haggie, it is not the worst hack in the
> >  world, and maybe we can live with it, but lets understand the trade
> >  offs carefully]
> 
> As Haggai wrote, if we let the using IP address thing to fly up, we have
> support for RDMA in containers using the RDMA-CM at IPoIB environments.
> This will let people test, use, experiment, fix, interact (and even
> production-it when static IP address assignment scheme is used).

I just noticed ipvlan got merged a few months ago.. That certainly
changed my view on this topic. It is basically a software
version of the same-guid ipoib children scheme. Similar issues: Same MAC
address as the parent, IPv6 SLAAC is disabled (?),  DHCP has similar
issue (solved with RFC4361, and broadcasting fallback, it seems)..

The l2/l3 distinction in ipvlan is also very interesting. The L3 mode
solves some of the security type issues. What do you think Haggi?

Is there any chance standard things like ipvlan and macvlan could be
used with rdma-cm if their master devices are IPoIB? Are we even on
the right path to do that someday? Is that the plan for roce?

Any thoughts on the idea we still need ipoib same-guid children if
ipvlan is available?

Jason
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
