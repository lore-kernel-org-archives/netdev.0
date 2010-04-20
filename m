From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [net-next,1/2] add iovnl netlink support
Date: Tue, 20 Apr 2010 18:19:32 +0200
Message-ID: <201004201819.32970.arnd@arndb.de>
References: <20100419191807.10423.84600.stgit@savbu-pc100.cisco.com> <201004201657.02873.arnd@arndb.de> <20100420152206.GA24942@x200.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Scott Feldman <scofeldm@cisco.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Chris Wright <chrisw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:50081 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753995Ab0DTQTk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Apr 2010 12:19:40 -0400
In-Reply-To: <20100420152206.GA24942@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 20 April 2010, Chris Wright wrote:
> * Arnd Bergmann (arnd@arndb.de) wrote:
> > On Tuesday 20 April 2010, Chris Wright wrote:
> >
> > After thinking some more about this case, I now believe we should do
> > it the other way around, and have lldpad in control of this interface
> > from the user space side, and letting user programs (lldptool, libvirt,
> > ...) talk to lldpad in order to set it up.
> 
> lldpad won't be involved in all cases, yet a mgmt tool like libvirt will.
> so this seems backwards.

Well, that part is still the matter of this discussion, as far as I can tell ;-)

> > But that's only the case if the NIC itself is in VEPA mode. If that
> > were the case, there would be no need for a kernel interface at all,
> > because then we could just drive the port profile selection from user
> > space.
> > 
> > The proposed interface only seems to make sense if you use it to
> > configure the NIC itself! Why should it care about the port profile
> > otherwise?
> 
> In the case of devices that can do adjacent switch negotiations directly.

I thought the idea to deal with those devices was to beat sense into
the respective developers until they do the negotiation in software 8-)

> > > > Same here: Should you be able to set multiple MAC addresses, or
> > > > trunk mode? Can the VF override it?
> > > > Also, for the new multi-channel VEPA, I'd guess that you also need
> > > > to supply an 802.1ad S-VLAN ID.
> > > 
> > > Something like set_port_profile() would initiate the negotiation for the
> > > s-vlan id for a particular channel, not sure it's needed as part of the
> > > netlink interface or not.
> > 
> > Well, you have to set up the s-vlan ID in order to have something to
> > set the port profile in.
> 
> Right, depends if the use the port profile to establish the channel and
> negotiate the s-vlan ID.  I don't recall the order there.

I'm pretty sure that setting up the channel (for 802.1bg) is done before
any port profile comes in.

	Arnd
