From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [net-next,1/2] add iovnl netlink support
Date: Thu, 22 Apr 2010 20:48:53 +0200
Message-ID: <201004222048.53950.arnd@arndb.de>
References: <C7F4AD4F.2A34D%scofeldm@cisco.com> <201004220851.05756.arnd@arndb.de> <20100422174729.GK28829@x200.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Scott Feldman <scofeldm@cisco.com>, davem@davemloft.net,
	netdev@vger.kernel.org, Mitch Williams <mitch.a.williams@intel.com>
To: Chris Wright <chrisw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:58343 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752367Ab0DVSti (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 14:49:38 -0400
In-Reply-To: <20100422174729.GK28829@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 22 April 2010 19:47:29 Chris Wright wrote:
> OK, wasn't clear if you meant that or simply 100% dedicating the interface
> via something like virtio.  The add_vf() idea, while neat, doesn't really
> match how VF's are allocated.

But we still need something like that for allocating queues in VMDq
and similar cases where we do not have pass-through, right?

As far as I can tell we don't have an interface for that yet, but
we have drivers for a number of cards that could do this.

> > I don't have an SR-IOV card available for testing yet. How is this
> > configured now?
> 
> The device shows up in the host as a normal network device, so mgmt tools
> currently treat it as if it's no different from a PF.  So that's just
> plain old:
> 
> SIOCSIFHWADDR or RTM_SETLINK (i.e. normal ->ndo_set_mac_addr)

Ok, but that only works for a fixed number of VFs and you can only
configure the VF before it's assigned to the guest, right?

Both are not serious limitations, but it would be nice to
have an easy way around them. In particular, for assigning
the mac address and vlan id (VF in access mode), there needs
to be some interface that allows the host but not the guest
to change the settings after assigning the card to the guest.

This is a fundamental requirement for VEPA, because the switch
applied its forwarding rules based on the mac address and trusts
the hypervisor to make sure it cannot be faked by the guest.

	Arnd
