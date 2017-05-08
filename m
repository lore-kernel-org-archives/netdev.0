From: "Chiappero, Marco" <marco.chiappero@intel.com>
Subject: RE: [PATCH net-next 9/9] ipvlan: introduce individual MAC addresses
Date: Mon, 8 May 2017 15:29:09 +0000
Message-ID: <695CDAEB5A6CE2498DE413F2A9AA829609161324@IRSMSX101.ger.corp.intel.com>
References: <20170427145142.15830-1-marco.chiappero@intel.com>
        <20170427145142.15830-10-marco.chiappero@intel.com>
        <1493310033.27948.3.camel@redhat.com>   <1493310219.27948.5.camel@redhat.com>
        <695CDAEB5A6CE2498DE413F2A9AA82960915DF0C@IRSMSX101.ger.corp.intel.com>
        <1493741366.32411.7.camel@redhat.com>
        <695CDAEB5A6CE2498DE413F2A9AA82960915EF08@IRSMSX101.ger.corp.intel.com>
 <20170504184345.3f9afb8e@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Dan Williams <dcbw@redhat.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "David S . Miller" <davem@davemloft.net>,
        "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
        "Duyck, Alexander H" <alexander.h.duyck@intel.com>,
        "Grandhi, Sainath" <sainath.grandhi@intel.com>,
        Mahesh Bandewar <maheshb@google.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:38195 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752459AbdEHP3X (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 8 May 2017 11:29:23 -0400
In-Reply-To: <20170504184345.3f9afb8e@griffin>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> -----Original Message-----
> From: Jiri Benc [mailto:jbenc@redhat.com]
> Sent: Thursday, May 4, 2017 5:44 PM
> To: Chiappero, Marco <marco.chiappero@intel.com>
> Cc: Dan Williams <dcbw@redhat.com>; netdev@vger.kernel.org; David S .
> Miller <davem@davemloft.net>; Kirsher, Jeffrey T
> <jeffrey.t.kirsher@intel.com>; Duyck, Alexander H
> <alexander.h.duyck@intel.com>; Grandhi, Sainath
> <sainath.grandhi@intel.com>; Mahesh Bandewar <maheshb@google.com>
> Subject: Re: [PATCH net-next 9/9] ipvlan: introduce individual MAC addresses
> 
> On Thu, 4 May 2017 09:37:00 +0000, Chiappero, Marco wrote:
> > This looks conceptually wrong. Yes, ipvlan works at L3 (which is an
> > implementation detail anyway), but slaves are Ethernet interfaces and
> > should behave as much as possible as such regardless, with an
> > individual MAC address assigned.
> 
> Isn't the proper fix then converting ipvlan interfaces to be L3 only interfaces?
> I.e., ARPHRD_NONE? There's not much ipvlan can do with arbitrary Ethernet
> frames anyway. Of course, a flag to switch to the new behavior would be
> needed in order to preserve backwards compatibility.

Yes, L3 only interfaces would be a valid solution and a major differentiation with respect to macvlan. In fact it's been considered but abandoned because:
- it would be a break from the past
- VMs and containers usually expect Ethernet devices

Having that said, I'm ok with this solution if deemed preferable.
 
> This patchset looks very wrong. For proper support of multiple MAC addresses,
> we have macvlan and it's pointless to add that to ipvlan.

Ipvlan will never have proper support for L2, it's a L3 thing and doesn't aim at replacing macvlan. So, the options are:
1) remove it and provide L3 only interfaces - as you are proposing
2) fully emulate it preserving the single unicast MAC rule - my proposal

I'm open to both solutions, to me the important thing is to address the problems with the current implementation, one way or another, making it comply with basic networking concepts and expectations.

> And doing some kind of weird MAC NAT in ipvlan just to satisfy broken tools that
> can't cope with multiple interfaces with the same MAC address is wrong, too.

Ipvlan has always had the MAC issue, regardless, these tools simply make it more apparent. And as I said already, whether they are broken is debatable (yet I have to read a reasonable motivation). At the very least their expectation to have unique addresses on the same broadcast domain is hardly arguable. Should ipvlan considered special? Again, questionable.

> Those tools are already broken anyway, there's nothing preventing anyone to
> set the same MAC address to multiple interfaces.

What are you trying to demonstrate, that you can shoot yourself in the foot? That you can interfere with the controller? That you can intentionally break your network? Yes, of course you can, so what?
As long as network components comply with expected behaviors, including the ability to change the MAC address, every orchestrator will do its job of managing the network and will do it correctly.

> I suppose those tools don't work with bonding and bridge, either?

NaaS software and SDN controllers are built around bridges, a bridge is a well-defined, coherent, fundamental network component. As soon as ipvlan will behave coherently as well, upper layers will handle it properly.
By the way, none of them has the same limitations of ipvlan.
 
> > So, either we fix this by forcing slaves to stay in sync with master,
> 
> Yes, that's the correct behavior. Well, at least as correct as one can get with the
> ipvlan broken design of pretending that an interface is L2 when in fact, it is not.

Eventually we got there:  "ipvlan broken design". Let's fix it then. Would moving to L3 only interfaces be accepted instead?
--------------------------------------------------------------
Intel Research and Development Ireland Limited
Registered in Ireland
Registered Office: Collinstown Industrial Park, Leixlip, County Kildare
Registered Number: 308263


This e-mail and any attachments may contain confidential material for the sole
use of the intended recipient(s). Any review or distribution by others is
strictly prohibited. If you are not the intended recipient, please contact the
sender and delete all copies.
