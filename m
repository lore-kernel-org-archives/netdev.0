From: Ben Hutchings <bhutchings@solarflare.com>
Subject: RE: [RFC PATCH 1/4] net: Add support to netdev ops for changing
	hardware queue MAC and VLAN filters
Date: Mon, 23 Nov 2009 13:22:50 +0000
Message-ID: <1258982570.2845.8.camel@achroite.uk.solarflarecom.com>
References: <20091117214923.15119.98918.stgit@localhost.localdomain>
	 <1258573987.2780.20.camel@achroite.uk.solarflarecom.com>
	 <EA929A9653AAE14F841771FB1DE5A1365FA69A3162@rrsmsx501.amr.corp.intel.com>
	 <1258586065.2780.31.camel@achroite.uk.solarflarecom.com>
	 <EA929A9653AAE14F841771FB1DE5A1365FA69A337F@rrsmsx501.amr.corp.intel.com>
	 <1258642493.2837.8.camel@achroite.uk.solarflarecom.com>
	 <EA929A9653AAE14F841771FB1DE5A1365FA6A1FF82@rrsmsx501.amr.corp.intel.com>
	 <1258657155.2837.10.camel@achroite.uk.solarflarecom.com>
	 <EA929A9653AAE14F841771FB1DE5A1365FA6A200AD@rrsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: "Williams, Mitch A" <mitch.a.williams@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:55930 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751992AbZKWNWv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 08:22:51 -0500
In-Reply-To: <EA929A9653AAE14F841771FB1DE5A1365FA6A200AD@rrsmsx501.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-11-19 at 12:34 -0700, Williams, Mitch A wrote:
> >From: Ben Hutchings [mailto:bhutchings@solarflare.com]
> >Sent: Thursday, November 19, 2009 10:59 AM
> 
> >> Please explain specifically what you perceive to be the difference
> >between:
> >>
> >> $ ip link set eth1 queue 1 mac <blah>
> >> $ ip link set eth1 queue 1 vlan <foo>
> >>
> >> and
> >>
> >> $ ip link set eth1 queue 1 mac <blah> vlan <foo>
> >>
> >> The two filter types are, in my mind, completely orthogonal.  You can
> >> have one, or the other, or both, or neither. What do we gain by
> >> glomming both options on one command line?  And is this worth the
> >> tradeoff of more complex code?
> >
> >I think you need to state clearly what semantics you are now proposing
> >before I can make any judgement on them.
> >
> 
> OK, now I'm really confused, Ben. It seems that we are both asking
> each other the same question.
> 
> What I'm proposing is really the same as we have now for single-queue
> devices:
> 
> - A MAC filter is enabled by default. If you want to change the MAC
> address, you use a tool (ip or ifconfig) to change it.
> 
> - A VLAN filter is not enabled by default. If you want to filter on
> VLANs, then you load the 8021q module, and enable a filter.

This doesn't seem quite the same to me, but I'll not argue this.

> The MAC filter is configured completely separately from the VLAN
> filter. Either one can be changed without affecting the other one and,
> in fact, you use two different tools to do these operations.
> 
> For SR-IOV VF devices, my proposed changes implement exactly the same
> thing.  You use one command to change the MAC address.  You use
> another command to change the VLAN filter. Changing one does not
> affect the other.
> 
> In this case, we use the same tool for both operations, but they're
> still separate operations.

This makes some sense, and I accept that it's rather different from
filtering for delivery to the host.

> N.B.
> The major difference in VLAN filtering is that this implementation
> allows the VF to participate in only one VLAN, and the filter is
> applied independently of the VF driver. So you can put a specific VM
> on a VLAN without its knowledge. If you want the VM to have more
> intelligent VLAN filtering, you don't use this filter, and you load
> 8021q in the VM and set your filters there.

How does this interact with use of multiple queues within a single
function?  Are the specified queue numbers really interpreted as RX
queue indices or as function numbers?

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

