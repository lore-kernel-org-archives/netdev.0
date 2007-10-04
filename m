From: Urs Thuermann <urs@isnogud.escape.de>
Subject: Re: [PATCH 2/7] CAN: Add PF_CAN core module
Date: 04 Oct 2007 13:51:47 +0200
Message-ID: <ygfbqbf14j0.fsf@janus.isnogud.escape.de>
References: <20071002131006.31727.0@janus.isnogud.escape.de>
	<20071002131108.31727.2@janus.isnogud.escape.de>
	<20071002143855.GG7881@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver@hartkopp.net>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
To: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from oker.escape.de ([194.120.234.254]:36055 "EHLO oker.escape.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757200AbXJDLzr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Oct 2007 07:55:47 -0400
In-Reply-To: <20071002143855.GG7881@ghostprotocols.net>; from Arnaldo Carvalho de Melo on Tue, 2 Oct 2007 11:38:55 -0300
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnaldo Carvalho de Melo <acme@ghostprotocols.net> writes:

> > +struct sockaddr_can {
> > +	sa_family_t can_family;
> > +	int         can_ifindex;
> > +	union {
> > +		struct { canid_t rx_id, tx_id; } tp16;
> > +		struct { canid_t rx_id, tx_id; } tp20;
> > +		struct { canid_t rx_id, tx_id; } mcnet;
> > +		struct { canid_t rx_id, tx_id; } isotp;
> > +	} can_addr;
> 
> Again being curious, what is the value of this union of all its members
> have the same definition? Backward source code compatibility?

As Oliver already wrote, different CAN transport protocols may use
different sockaddr structures.  Therefore, we have made can_addr a
union.  The four we have defined already, all look the same, but
other, future protocols may define a different structure.

> > +struct can_proto {
> > +	int              type;
> > +	int              protocol;
> > +	int              capability;
> > +	struct proto_ops *ops;
> > +	struct proto     *prot;
> > +};
> > +
> > +/* function prototypes for the CAN networklayer core (af_can.c) */
> > +
> > +extern int  can_proto_register(struct can_proto *cp);
> > +extern void can_proto_unregister(struct can_proto *cp);
> 
> We have proto registering infrastructure for bluetooth, inet and now
> CAN, have you looked at:
> 
> struct inet_protosw;
> proto_{register,unregister}, etc?

Yes, I know inet_protosw and inet_{,un}register_protosw().  But we
can't use inet_register_protosw().

And can_proto_register() does use proto_register().  What exactly do
you want to suggest?

urs
