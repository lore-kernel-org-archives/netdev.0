From: Kurt Van Dijck <kurt.van.dijck@eia.be>
Subject: Re: [PATCH net-next-2.6 v2] can: convert protocol handling to RCU
Date: Wed, 6 Apr 2011 17:34:40 +0200
Message-ID: <20110406153440.GA2277@kurt.e-circ.dyndns.org>
References: <4D9B58EC.9090903@hartkopp.net>
 <20110406092727.GC342@kurt.e-circ.dyndns.org>
 <4D9C7B07.20903@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Urs Thuermann <urs@isnogud.escape.de>
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.eia.be ([194.78.71.18]:28221 "EHLO mail.eia.be"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932131Ab1DFPep (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Apr 2011 11:34:45 -0400
Content-Disposition: inline
In-Reply-To: <4D9C7B07.20903@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 06, 2011 at 04:39:03PM +0200, Oliver Hartkopp wrote:
> On 06.04.2011 11:27, Kurt Van Dijck wrote:
> > On Tue, Apr 05, 2011 at 08:01:16PM +0200, Oliver Hartkopp wrote:
> 
> >>  
> >> +static struct can_proto *can_try_module_get(int protocol)
> >> +{
> >> +	struct can_proto *cp;
> >> +
> >> +	rcu_read_lock();
> >> +	cp = rcu_dereference(proto_tab[protocol]);
> >> +	if (cp && !try_module_get(cp->prot->owner))
> > After the xxx_get, is the 'cp' pointer persistent?
> 
> try_module_get() increases the usage counter of the module - therefore it is.
> It is protected until module_put(cp->prot->owner) at the end of can_create() .
Ok, I understand correctly now.
> 
> >>  	/* check for available protocol and correct usage */
> >>  
> >>  	if (!cp)
> >>  		return -EPROTONOSUPPORT;
> >>  
> >>  	if (cp->type != sock->type) {
> > I don't see how this will evaluate to true?
> > can_proto_register takes care of it.
> 
> This check compares the type of the socket that is to be created with the type
> that's defined for this protocol.
> 
> E.g. if you would give
> 
> s = socket(PF_CAN, SOCK_STREAM, CAN_RAW);
> 
> instead of the correct
> 
> s = socket(PF_CAN, SOCK_RAW, CAN_RAW);
> 
> you will get this error.

Right, I see my mistake now.
> 
> >> -		err = -EPROTONOSUPPORT;
> >> +		err = -EPROTOTYPE;
> >>  		goto errout;
> >>  	}
> >>  
> 
> Regards,
> Oliver

Regards,
Kurt

Acked-by: Kurt Van Dijck <kurt.van.dijck@eia.be>
