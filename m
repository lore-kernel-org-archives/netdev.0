From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [net-next,1/2] add iovnl netlink support
Date: Wed, 21 Apr 2010 20:04:36 +0200
Message-ID: <201004212004.36674.arnd@arndb.de>
References: <C7F475A7.2A1D9%scofeldm@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Chris Wright <chrisw@redhat.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Scott Feldman <scofeldm@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.10]:51033 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752638Ab0DUSE5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Apr 2010 14:04:57 -0400
In-Reply-To: <C7F475A7.2A1D9%scofeldm@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 21 April 2010, Scott Feldman wrote:
> On 4/21/10 6:17 AM, "Arnd Bergmann" <arnd@arndb.de> wrote:
> > More importantly, the card cannot possibly do the protocol by itself,
> > because the information that gets exchanged is specific to the hypervisor and
> > the guest, not to the hardware. What you have implemented is another protocol
> > between the hypervisor and the NIC that exchanges the exact same data that
> > then gets sent to the switch. We already need to have an implementation that
> > sends this data to the switch from user space for all cards that don't do
> > it in firmware, so doing an alternative path in the adapter really creates
> > more work for the users, and means that when we fix bugs or add features
> > to the common code, you don't get them ;-).
> 
> But the point of iovnl was to provide a single mechanism for both types of
> adapters (w/ or w/o firmware assist) to exchange this data with the switch,
> therefore making the difference in the adapters transparent to the user.  So
> I'm missing your point about more work for the users.

It creates an extra step: Normally we'd simply implement the network protocol
in user space, e.g. in lldpad and have other code use the lldptool command
line interface to start the negotiation.

Now we have a user protocol based on netlink that is about as complex as the
wire protocol itself, at least if you want to implement both the standard
VDP and the Cisco variant, and do all the interesting parts like guest migration
and synchronously waiting for the negotiation to complete.

	Arnd
