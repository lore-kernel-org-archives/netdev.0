From: David Miller <davem@davemloft.net>
Subject: Re: [RFC usbnet.c] - Add packet aggregation capability
Date: Thu, 11 Jun 2009 05:38:30 -0700 (PDT)
Message-ID: <20090611.053830.39176651.davem@davemloft.net>
References: <1244656659.2845.11.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: david-b@pacbell.net, netdev@vger.kernel.org, mark@asix.com.tw,
	donald@asix.com.tw, louis@asix.com.tw
To: dhollis@davehollis.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42682
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750714AbZFKMi2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 08:38:28 -0400
In-Reply-To: <1244656659.2845.11.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Hollis <dhollis@davehollis.com>
Date: Wed, 10 Jun 2009 13:57:39 -0400

> One item that I have is how to handle the portion in usbnet_probe() that
> sets the hard_start_xmit handler with the change to netdevice_ops:
> 
> -	net->hard_start_xmit = usbnet_start_xmit;
> +	if (info->tx_gather)
> +		net->hard_start_xmit = usbnet_bundle_xmit;
> +	else
> +		net->hard_start_xmit = usbnet_start_xmit;
> 
> 
> Would it be the most appropriate to merge the
> usbnet_aggregate_skb_xmit() pieces into the existing usbnet_start_xmit
> with appropriate conditionals?

In the current tree you cannot even make this assignment.

Everything must go through a net_device_ops set of methods,
the pointer of which is const.
