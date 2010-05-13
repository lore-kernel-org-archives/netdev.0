From: Chris Wright <chrisw@redhat.com>
Subject: Re: [net-next-2.6 V6 PATCH 1/2] Add netlink support for virtual port
 management (was iovnl)
Date: Thu, 13 May 2010 14:18:47 -0700
Message-ID: <20100513211847.GE30483@x200.localdomain>
References: <20100513201714.25579.53530.stgit@savbu-pc100.cisco.com>
 <20100513201720.25579.51230.stgit@savbu-pc100.cisco.com>
 <4BEC63DB.2090306@trash.net>
 <20100513204614.GB30483@x200.localdomain>
 <4BEC65BC.5040208@trash.net>
 <20100513210828.GD30483@x200.localdomain>
 <4BEC6B19.1040808@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chris Wright <chrisw@redhat.com>,
	Scott Feldman <scofeldm@cisco.com>, davem@davemloft.net,
	netdev@vger.kernel.org, arnd@arndb.de
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50991 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752271Ab0EMVTE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 May 2010 17:19:04 -0400
Content-Disposition: inline
In-Reply-To: <4BEC6B19.1040808@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Patrick McHardy (kaber@trash.net) wrote:
> Chris Wright wrote:
> > * Patrick McHardy (kaber@trash.net) wrote:
> >> Chris Wright wrote:
> >>> * Patrick McHardy (kaber@trash.net) wrote:
> >>>>> +	} else  {
> >>>>> +		err = rtnl_vf_port_fill_nest(skb, dev, -1);
> >>>> What does -1 mean?
> >>> It means no VFs.  Could be made a macro/enum constant
> >> Why call rtnl_vg_port_fill_nest at all in that case? It even
> >> calls the ndo_get_vf_port() callback.
> > 
> > For the case where port profile is set on net dev that does not
> > have VFs (e.g. the enic case in 2/2).
> 
> Thanks for the explanation. I guess a enum constant would be nice
> to have. But the bigger problem is the asymetrical message
> parsing/construction.

Yeah, what would you like to do there?  I think we have to keep the
existing, just break out symmtetic set/get?

> BTW:
> 
> > +enum {
> > +	VF_PORT_REQUEST_PREASSOCIATE = 0,
> > +	VF_PORT_REQUEST_PREASSOCIATE_RR,
> > +	VF_PORT_REQUEST_ASSOCIATE,
> > +	VF_PORT_REQUEST_DISASSOCIATE,
> > +};
> 
> Do multiple of these commands have to be issued in order to
> reach "associated" state? That also wouldn't fit into the
> rtnetlink design, which contains state, not commands.

It's optional.  At the very least, you need 1 associate/disassociate for
each logical link up/down.

For VM migration or (perhaps failover modes) you can optionally issue a
preassociate.  Preassociate has 2 flavors.  One which is purely advisory,
another which will reserve resources on the switch.  These all reprsent
state transitions in the switch, but only associate should allow final
logical link up and traffic to flow.

thanks,
-chris

