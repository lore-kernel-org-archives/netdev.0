From: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v4 for-next 00/12] Add network namespace support in the
 RDMA-CM
Date: Mon, 8 Jun 2015 10:52:34 +0300
Message-ID: <557549C2.2080605@mellanox.com>
References: <1432837360.114391.35.camel@redhat.com>
 <CAJ3xEMh2T5-56rFxWVdct2uAZYW1ZrKivWfS45V-mvhAfwyGaA@mail.gmail.com>
 <1432850150.114391.56.camel@redhat.com> <556ED0D5.8010502@mellanox.com>
 <20150603161447.GC12073@obsidianresearch.com>
 <CAJ3xEMjM53sYuEgQV3WPaN4WErk_YcojPY2zBcmq-+3W2dfD+A@mail.gmail.com>
 <20150603195325.GC7902@obsidianresearch.com>
 <CAJ3xEMiO+hEzOJ2oJ5G-mmBeaX4ZHvUyhNSAzsrRDui6dFjvCg@mail.gmail.com>
 <20150603234811.GA15128@obsidianresearch.com> <556FEF25.80409@mellanox.com>
 <20150604164058.GB27699@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"Or Gerlitz" <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	"Shachar Raindel" <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150604164058.GB27699-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 04/06/2015 19:40, Jason Gunthorpe wrote:
> Discussion idea: Can we actually use the netstack to process the
> RDMA-CM packets? It looks like the netstack wants a skb to do this
> mid-layer work, so rdma-cm would have to synthesize a skb for the CM
> packets and pass it through netdev to apply all the transformations
> and access the various internal states (eg from ipvlan, bonding,
> etc). rdma-cm would have to 'catch' the skb once it is done traveling
> and resume its normal processing. Very similar to your notion of using
> UDP, but without any on-the-wire change.
> 
> This would fit in that same ingress spot I suggested adding the
> routing lookup, instead of routing we want the full stack to have a go
> at figuring out the final netdev.
> 
> This seems the most general because it will work for all the *vlan
> type drivers, bonding, and all of the RDMA technologies. (each would
> have a slightly different way to make the skb, but same basic idea)
> 
> Lots and lots of details to do that, but conceptually it seems pretty
> solid?

The problem is that the network stack can do all sort of changes to the
packets (like NAT), and it may be the case that the hardware can't
reflect these changes later on when creating a QP. I think it would be
best to stick with resolving the net_dev using the request parameters,
and the simpler routing lookup. This way RDMA CM remains in control, and
if the user configures routing in an unexpected way, it can just block
the request.

Haggai
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
