From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [net-next-2.6 V8 PATCH 1/2] Add netlink support for virtual port management (was iovnl)
Date: Sat, 15 May 2010 11:07:51 +0200
Message-ID: <201005151107.51522.arnd@arndb.de>
References: <20100515010415.21260.35219.stgit@savbu-pc100.cisco.com> <20100515010429.21260.46950.stgit@savbu-pc100.cisco.com> <20100515031130.GD5798@x200.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Scott Feldman <scofeldm@cisco.com>, davem@davemloft.net,
	netdev@vger.kernel.org, kaber@trash.net
To: Chris Wright <chrisw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.10]:62405 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752903Ab0EOJII (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 May 2010 05:08:08 -0400
In-Reply-To: <20100515031130.GD5798@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 15 May 2010 05:11:30 Chris Wright wrote:
> * Scott Feldman (scofeldm@cisco.com) wrote:
> > From: Scott Feldman <scofeldm@cisco.com>
> > 
> > Add new netdev ops ndo_{set|get}_vf_port to allow setting of
> > port-profile on a netdev interface.  Extends netlink socket RTM_SETLINK/
> > RTM_GETLINK with two new sub msgs called IFLA_VF_PORTS and IFLA_PORT_SELF
> > (added to end of IFLA_cmd list).  These are both nested atrtibutes
> > using this layout:
> > 
> >               [IFLA_NUM_VF]
> >               [IFLA_VF_PORTS]
> >                       [IFLA_VF_PORT]
> >                               [IFLA_PORT_*], ...
> >                       [IFLA_VF_PORT]
> >                               [IFLA_PORT_*], ...
> >                       ...
> >               [IFLA_PORT_SELF]
> >                       [IFLA_PORT_*], ...
> > 
> > These attributes are design to be set and get symmetrically.  VF_PORTS
> > is a list of VF_PORTs, one for each VF, when dealing with an SR-IOV
> > device.  PORT_SELF is for the PF of the SR-IOV device, in case it wants
> > to also have a port-profile, or for the case where the VF==PF, like in
> > enic patch 2/2 of this patch set.
> > 
> > A port-profile is used to configure/enable the external switch virtual port
> > backing the netdev interface, not to configure the host-facing side of the
> > netdev.  A port-profile is an identifier known to the switch.  How port-
> > profiles are installed on the switch or how available port-profiles are
> > made know to the host is outside the scope of this patch.
> > 
> > There are two types of port-profiles specs in the netlink msg.  The first spec
> > is for 802.1Qbg (pre-)standard, VDP protocol.  The second spec is for devices
> > that run a similar protocol as VDP but in firmware, thus hiding the protocol
> > details.  In either case, the specs have much in common and makes sense to
> > define the netlink msg as the union of the two specs.  For example, both specs
> > have a notition of associating/deassociating a port-profile.  And both specs
> > require some information from the hypervisor manager, such as client port
> > instance ID.
> > 
> > The general flow is the port-profile is applied to a host netdev interface
> > using RTM_SETLINK, the receiver of the RTM_SETLINK msg communicates with the
> > switch, and the switch virtual port backing the host netdev interface is
> > configured/enabled based on the settings defined by the port-profile.  What
> > those settings comprise, and how those settings are managed is again
> > outside the scope of this patch, since this patch only deals with the
> > first step in the flow.
> > 
> > Signed-off-by: Scott Feldman <scofeldm@cisco.com>
> > Signed-off-by: Roopa Prabhu<roprabhu@cisco.com>
> 
> Assuming the SR-IOV VFINFO changes go in there will be some minor patch
> conflicts to be sorted out.

Right, I assume the best resolution then would be drop IFLA_VF_PORTS and
put the IFLA_VF_PORT attribute inside IFLA_VF_INFO, correct?

> Acked-by: Chris Wright <chrisw@redhat.com>

Acked-by: Arnd Bergmann <arnd@arndb.de>
