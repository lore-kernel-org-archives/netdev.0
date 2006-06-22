From: "Stephens, Allan" <allan.stephens@windriver.com>
Subject: RE: [PATCH 7/32] [TIPC] Multicast link failure now resets all links to "nacking" node.
Date: Thu, 22 Jun 2006 13:33:41 -0700
Message-ID: <3A30AD378ECC6F41A4AC64F18E8B3F7F48EA08@ala-mail04.corp.ad.wrs.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "David Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:1485 "EHLO mail.wrs.com")
	by vger.kernel.org with ESMTP id S1161335AbWFVUeO convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 16:34:14 -0400
Content-class: urn:content-classes:message
To: "James Morris" <jmorris@namei.org>,
	"Per Liden" <per.liden@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Nice observation, James.  As a relative newcomer to the official Linux
kernel development world, I'm impressed that non-TIPC folks are looking
at TIPC changes closely enough to see things like this!

Per, I'll leave it to you to decide if you want to address James's
concern.  But be aware that the link_reset_all() routine is only called
to handle emergency situations when TIPC's multicast link has run into
serious problems and is trying to recover.  Most systems will never
follow this path, so the cost of the unnecessary
local_bh_disable()/local_bh_enable() pairing shouldn't have any real
impact on the overall performance of TIPC.

Regards,
Al Stephens

> -----Original Message-----
> From: James Morris [mailto:jmorris@namei.org] 
> Sent: Thursday, June 22, 2006 2:51 PM
> To: Per Liden
> Cc: David Miller; netdev@vger.kernel.org; Stephens, Allan
> Subject: Re: [PATCH 7/32] [TIPC] Multicast link failure now 
> resets all links to "nacking" node.
> 
> On Thu, 22 Jun 2006, Per Liden wrote:
> 
> > +static void link_reset_all(unsigned long addr) {
> > +	struct node *n_ptr;
> > +	char addr_string[16];
> > +	u32 i;
> > +
> > +	read_lock_bh(&tipc_net_lock);
> > +	n_ptr = tipc_node_find((u32)addr);
> > +	if (!n_ptr) {
> > +		read_unlock_bh(&tipc_net_lock);
> > +		return;	/* node no longer exists */
> > +	}
> > +
> > +	tipc_node_lock(n_ptr);
> 
> You already have bh's disabled here, and tipc_node_lock() 
> also disables them.
> 
> Not sure if it's really worth worrying about but if so, you 
> could perhaps implement tipc_node_lock_bh() and tipc_node_lock().
> 
> 
> 
> - James
> -- 
> James Morris
> <jmorris@namei.org>
> 
