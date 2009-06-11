From: David Hollis <dhollis@davehollis.com>
Subject: Re: [RFC usbnet.c] - Add packet aggregation capability
Date: Thu, 11 Jun 2009 09:30:46 -0400
Message-ID: <1244727046.10611.1.camel@localhost.localdomain>
References: <1244656659.2845.11.camel@localhost.localdomain>
	<20090611.053830.39176651.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: david-b@pacbell.net, netdev@vger.kernel.org, mark@asix.com.tw,
	donald@asix.com.tw, louis@asix.com.tw
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms173007pub.verizon.net ([206.46.173.7]:60523 "EHLO
	vms173007pub.verizon.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750948AbZFKOHV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 10:07:21 -0400
Received: from smtp.davehollis.com ([173.65.162.118])
 by vms173007.mailsrvcs.net
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008; 32bit))
 with ESMTPA id <0KL200H0HTJGW6N7@vms173007.mailsrvcs.net> for
 netdev@vger.kernel.org; Thu, 11 Jun 2009 08:30:53 -0500 (CDT)
In-reply-to: <20090611.053830.39176651.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-06-11 at 05:38 -0700, David Miller wrote:
> From: David Hollis <dhollis@davehollis.com>
> Date: Wed, 10 Jun 2009 13:57:39 -0400
> 
> > One item that I have is how to handle the portion in usbnet_probe() that
> > sets the hard_start_xmit handler with the change to netdevice_ops:
> > 
> > -	net->hard_start_xmit = usbnet_start_xmit;
> > +	if (info->tx_gather)
> > +		net->hard_start_xmit = usbnet_bundle_xmit;
> > +	else
> > +		net->hard_start_xmit = usbnet_start_xmit;
> > 
> > 
> > Would it be the most appropriate to merge the
> > usbnet_aggregate_skb_xmit() pieces into the existing usbnet_start_xmit
> > with appropriate conditionals?
> 
> In the current tree you cannot even make this assignment.
> 
> Everything must go through a net_device_ops set of methods,
> the pointer of which is const.

So I'd need to have to separate net_device_ops and set
net->hard_start_xmit to the appropriate one based on info->tx_gather
being defined.

Not a problem.


> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

