From: jamal <hadi@cyberus.ca>
Subject: Re: ethernet QoS support?
Date: 12 Jul 2004 22:33:26 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1089686006.1046.17.camel@jzny.localdomain>
References: <1C440F3C-D110-11D8-8B61-000393DBC2E8@freescale.com>
	 <1089621532.3063.8.camel@andromache>
	 <1089635216.1054.271.camel@jzny.localdomain>
	 <200407122117.44069.vkondra@mail.ru>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Glen Turner <glen.turner@aarnet.edu.au>,
        Sam Leffler <sam@errno.com>, Jeff Garzik <jgarzik@pobox.com>,
        Kumar Gala <kumar.gala@freescale.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Vladimir Kondratiev <vkondra@mail.ru>
In-Reply-To: <200407122117.44069.vkondra@mail.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


> > A mapping is being suggested. Qdiscs handle the queueing. Send it to
> > the driver/MAC layer with instructions of which queue it goes on.
>
> Problem is, I don't know how driver can dictate what qdiscs should be attached 
> to it. AFAIK, it is under 'tc' control. What I suggest, is to provide some 
> API for driver to configure its qdiscs.

I think driver doing this is the wrong abstraction layer..

How about this: Write a user space daemon that receives those 
L2 policy frames from the driver. Daemon then uses netlink to configure
the qdiscs appropriately. This replaces the human opertaor who would do
this in the case of a static setup.

> And most complex item: I don't know how to support intserv type of streams, 
> i.e. streams with admission control. let's say it is like RSVP with support 
> on link layer.

OK, so it is RSVP being used for policy config then?
You seem to indicate it RSVP-like? 

> Should I try to summarize QoS facilities defined in TGE (new standard for QoS 
> in 802.11)? I tried to do it once, but I don't feel I expressed it clearly.

I think so.

> One more reason why I prefer to use skb->priority over TOS: driver should be 
> protocol agnostic. It may be non-IP, and TOS may be missing.

The TOS was being used as an example. The VLAN code for example
sets skb->priority at L2 as well. So nothing protcol specific about 
skb->priority.

cheers,
jamal
