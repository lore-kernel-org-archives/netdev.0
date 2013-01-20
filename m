From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [RFC:] struct net_device_ops: Add function pointer to fill
 device specific ndisc information
Date: Sun, 20 Jan 2013 13:22:34 -0800
Message-ID: <20130120212233.GA6776@ppwaskie-mobl2.amr.corp.intel.com>
References: <50FC2EE4.3080705@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux1394-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org, stefanr@s5r6.in-berlin.de,
	davem@davemloft.net
To: Stephan Gatzka <stephan.gatzka@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:52925 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752508Ab3ATVWw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Jan 2013 16:22:52 -0500
Content-Disposition: inline
In-Reply-To: <50FC2EE4.3080705@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 20, 2013 at 06:52:36PM +0100, Stephan Gatzka wrote:
> I've implemented IPv6 over firewire. Right now I'm facing the
> problem that the corresponding RFC3146 requires very firewire
> specific information sent during neighborhood discovery.
> 
> There was already a discussion on the linux1394 mailing list
> (http://sourceforge.net/mailarchive/message.php?msg_id=30342089 and http://sourceforge.net/mailarchive/forum.php?thread_name=50E4A3E5.8080304%40gmail.com&forum_name=linux1394-devel)
> 
> 
> During that discussion all participants agreed that it makes no
> sense to introduce a dependency between the ndisc code and the
> firewire net driver.
> 
> So the most appealing option seems to be to introduce on more
> callback routine either in struct net_device or struct
> net_device_ops:
> 
> int (*ndo_fill_llao)(void *llao);
> 
> Because I'm not so familiar with the structure of the whole network
> infrastructure in Linux, I need some advice if struct net_device or
> struct net_device_ops is the right place.
> 
> Maybe it's worth to generalize this and do the same for IPv4/ARP
> because right now the ARP packets are mangled in the firewire net
> driver.
> 
> Nevertheless, I've to admit that right now it seems that only IPv6
> over firewire requires such a callback routine.

I'm no expert on firewire requirements, but if you go down the path
of adding a net_device_ops member, I'd recommend adding a pointer
to your own struct of ops.  This would be similar to wireless ops.

Only a suggestion, since you may still need to add more ops later
on, and this way you can contain the inflation to a firewire-specific
struct of function pointers.

Cheers,
-PJ
