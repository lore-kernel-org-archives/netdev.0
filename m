From: Matthew Wilcox <willy@debian.org>
Subject: Re: netdev_ops retraction
Date: Thu, 31 Jul 2003 12:12:41 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030731111241.GJ22222@parcelfarce.linux.theplanet.co.uk>
References: <20030730184416.GI22222@parcelfarce.linux.theplanet.co.uk> <20030730233541.GB7057@conectiva.com.br> <20030730164108.06062b72.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnaldo Carvalho de Melo <acme@conectiva.com.br>, willy@debian.org,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030730164108.06062b72.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Jul 30, 2003 at 04:41:08PM -0700, David S. Miller wrote:
> I'm ok with the simplified ethtool-only version too.
> 
> Although I'm confused about what kind of problem there is with
> netdev_ops being such a "large structure".

Hard to understand/keep track of is my main concern.  There was also
a namespace collision -- two functions called get_stats.  It's now
get_ethtool_stats.

> This is the kind of thing there'd be _ONE_ copy of in each driver,
> ala.
> 
> struct netdev_ops tg3_netdev_ops {
>  ...
> 	.foo	=	tg3_foo,
>  ...
> };
> 
> ...
> 	tp->dev->netdev_ops = &tg3_netdev_ops;
> ...
> 
> Right?

I'm glad you mentioned tg3 as an example, since it's one of the ones where
this isn't true.

        if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5700)
                tp->dev->hard_start_xmit = tg3_start_xmit_4gbug;
        else
                tp->dev->hard_start_xmit = tg3_start_xmit;

I fixed this with two netdev_ops structs, but imagine a driver with two
or three more cases like this and everything starts to look quite nasty.
I do think we want to do netdev_ops, but not now, and let's keep
netdev_ops and ethtool_ops separate.

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk
