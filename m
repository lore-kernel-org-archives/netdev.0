From: Ben Hutchings <bhutchings@solarflare.com>
Subject: RE: [net-next-2.6 PATCH 0/8 RFC v2] macvlan: MAC Address filtering
 support for passthru mode
Date: Thu, 17 Nov 2011 23:37:15 +0000
Message-ID: <1321573035.2749.31.camel@bwh-desktop>
References: <43F901BD926A4E43B106BF17856F075501A177719C@orsmsx508.amr.corp.intel.com>
	 <CAC49D8A.374FB%roprabhu@cisco.com>
	 <43F901BD926A4E43B106BF17856F075501A19FF1D8@orsmsx508.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Roopa Prabhu <roprabhu@cisco.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"sri@us.ibm.com" <sri@us.ibm.com>,
	"dragos.tatulea@gmail.com" <dragos.tatulea@gmail.com>,
	"arnd@arndb.de" <arnd@arndb.de>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"mst@redhat.com" <mst@redhat.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"mchan@broadcom.com" <mchan@broadcom.com>,
	"dwang2@cisco.com" <dwang2@cisco.com>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"kaber@trash.net" <kaber@trash.net>,
	"benve@cisco.com" <benve@cisco.com>
To: "Rose, Gregory V" <gregory.v.rose@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:25881 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752189Ab1KQXhV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 18:37:21 -0500
In-Reply-To: <43F901BD926A4E43B106BF17856F075501A19FF1D8@orsmsx508.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-10-20 at 13:43 -0700, Rose, Gregory V wrote:
> > -----Original Message-----
> > From: Roopa Prabhu [mailto:roprabhu@cisco.com]
[...]
> > Moving the ops to netdev should be trivial. You probably want the ops to
> > work on the VF via the PF, like the existing ndo_set_vf_mac etc.
> 
> That is correct, so we would need to add some way to pass the VF number to the op.
> In addition, there are use cases for multiple MAC address filters for the Physical
> Function (PF) so we would like to be able to identify to the netdev op that it is
> supposed to perform the action on the PF filters instead of a VF.
> 
> An example of this would be when an administrator has created some number of VFs
> for a given PF but is also running the PF in bridged (i.e. promiscuous) mode so that it
> can support purely SW emulated network connections in some VMs that have low network
> latency and bandwidth requirements while reserving the VFs for VMs that require the low latency, high throughput that directly assigned VFs can provide.  In this case an
> emulated SW interface in a VM is unable to properly communicate with VFs on the same
> PF because the emulated SW interface's MAC address isn't programmed into the HW filters
> on the PF.  If we could use this op to program the MAC address and VLAN filters of
> the emulated SW interfaces into the PF HW a VF could then properly communicate across
> the NIC's internal VEB to the emulated SW interfaces.
[...]

This would also be good for Solarflare's VF plugin architecture.  The VF
driver works as a plugin for virtio or xen_netfront and can refuse
packets that need to be bridged to another (physically) local address.
The PF driver has to tell VFs what the local addresses are and currently
relies on some custom scripting to know about those extra addresses.

(No, none of that is upstream - I'm preparing for that now.)

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
