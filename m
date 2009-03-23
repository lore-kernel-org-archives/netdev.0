From: David Miller <davem@davemloft.net>
Subject: Re: rndis_wlan netdev ops
Date: Mon, 23 Mar 2009 14:31:19 -0700 (PDT)
Message-ID: <20090323.143119.121196854.davem@davemloft.net>
References: <20090323.134318.106371116.davem@davemloft.net>
	<20090323140057.0f05c103@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32793
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752714AbZCWVbb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2009 17:31:31 -0400
In-Reply-To: <20090323140057.0f05c103@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 23 Mar 2009 14:00:57 -0700

> On Mon, 23 Mar 2009 13:43:18 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
> 
> > Probably what we'll have to do for this case is allocate a
> > netdev_ops copy so that the ->set_multicast_list can be set
> > to a new value.  But that defeats the whole purpose of netdev
> > ops so I assume you have other plans :-)
> 
> Why not just turn off the multicast bit in the device, or maybe
> the hardware developer can implement set_multicast_list

We could just import the parent OPS into a local const netdevice_ops
instance, that's how we handle this everywhere else.

To prevent changes in the parent being lost in the rndis driver we can
encapsulate the ops assignments into a macro used by both.  Taking the
set_multicast_list as an arg.

Alternatively the parent can provide a hook function pointer for this
multicast operation, which the parent runs when non-NULL.
