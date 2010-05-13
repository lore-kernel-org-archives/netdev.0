From: Chris Wright <chrisw@redhat.com>
Subject: Re: [net-next-2.6 V6 PATCH 1/2] Add netlink support for virtual port
 management (was iovnl)
Date: Thu, 13 May 2010 13:28:26 -0700
Message-ID: <20100513202826.GA30483@x200.localdomain>
References: <20100513201714.25579.53530.stgit@savbu-pc100.cisco.com>
 <20100513201720.25579.51230.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, chrisw@redhat.com,
	arnd@arndb.de
To: Scott Feldman <scofeldm@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:20821 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759035Ab0EMU2b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 May 2010 16:28:31 -0400
Content-Disposition: inline
In-Reply-To: <20100513201720.25579.51230.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Scott Feldman (scofeldm@cisco.com) wrote:
> From: Scott Feldman <scofeldm@cisco.com>
> 
> Add new netdev ops ndo_{set|get}_vf_port to allow setting of
> port-profile on a netdev interface.  Extends netlink socket RTM_SETLINK/
> RTM_GETLINK with new sub cmd called IFLA_VF_PORT (added to end of
> IFLA_cmd list).
> 
> A port-profile is used to configure/enable the external switch virtual port
> backing the netdev interface, not to configure the host-facing side of the
> netdev.  A port-profile is an identifier known to the switch.  How port-
> profiles are installed on the switch or how available port-profiles are
> made know to the host is outside the scope of this patch.
> 
> There are two types of port-profiles specs in the netlink msg.  The first spec
> is for 802.1Qbg (pre-)standard, VDP protocol.  The second spec is for devices
> that run a similar protocol as VDP but in firmware, thus hiding the protocol
> details.  In either case, the specs have much in common and makes sense to
> define the netlink msg as the union of the two specs.  For example, both specs
> have a notition of associating/deassociating a port-profile.  And both specs
> require some information from the hypervisor manager, such as client port
> instance ID.
> 
> The general flow is the port-profile is applied to a host netdev interface
> using RTM_SETLINK, the receiver of the RTM_SETLINK msg communicates with the
> switch, and the switch virtual port backing the host netdev interface is
> configured/enabled based on the settings defined by the port-profile.  What
> those settings comprise, and how those settings are managed is again
> outside the scope of this patch, since this patch only deals with the
> first step in the flow.
> 
> There is a RTM_GETLINK cmd to to return port-profile setting of an
> interface and to also return the status of the last port-profile
> association.
> 
> IFLA_VF_PORT is modeled after the existing IFLA_VF_* cmd where a
> VF number is passed in to identify the virtual function (VF) of an SR-IOV-
> capable device.  In this case, the target of IFLA_VF_PORT msg is the
> netdev physical function (PF) device.  The PF will apply the port-profile
> to the VF.  IFLA_VF_PORT can also be used for devices that don't
> adhere to SR-IOV and can apply the port-profile directly to the netdev
> target.  In this case, the VF number is ignored.
> 
> Passing in a NULL port-profile is used to delete the port-profile association.
> 
> Acked-by: Arnd Bergmann <arnd@arndb.de>
> Signed-off-by: Scott Feldman <scofeldm@cisco.com>
> Signed-off-by: Roopa Prabhu<roprabhu@cisco.com>

Nice, this looks good to me.

Acked-by: Chris Wright <chrisw@redhat.com>
