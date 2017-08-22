From: "Yang, Yi" <yi.y.yang@intel.com>
Subject: Re: [PATCH net-next v4] openvswitch: enable NSH support
Date: Tue, 22 Aug 2017 17:38:26 +0800
Message-ID: <20170822093825.GA94865@cran64.bj.intel.com>
References: <1503041071-68753-1-git-send-email-yi.y.yang@intel.com>
 <20170818152601.3760aaec@griffin>
 <20170821061109.GA72656@cran64.bj.intel.com>
 <20170821101925.3f9b36a1@griffin>
 <20170821083900.GA74649@cran64.bj.intel.com>
 <20170821111854.42dece9f@griffin>
 <20170821091541.GA75219@cran64.bj.intel.com>
 <20170821114713.7c6ebb9a@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "dev@openvswitch.org" <dev@openvswitch.org>,
        "blp@ovn.org" <blp@ovn.org>, "e@erig.me" <e@erig.me>,
        "jan.scheurich@ericsson.com" <jan.scheurich@ericsson.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:20217 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932306AbdHVJxE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 22 Aug 2017 05:53:04 -0400
Content-Disposition: inline
In-Reply-To: <20170821114713.7c6ebb9a@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 21, 2017 at 05:47:13PM +0800, Jiri Benc wrote:
> 
> > I don't know how we can support this, is it a must-have thing?
> 
> What would happen if you get a GSO packet? Ports of an ovs bridge claim
> GSO support, thus they may get a GSO packet. You have to handle it one
> way or the other: either software segment the packet before pushing the
> header, or implement proper GSO support for NSH.
> 

I checked GSO support code, we have two cases to handle, one case is to
output NSH packet to VxLAN-gpe port, the other case is to output NSH packet
to Ethernet port (tap, veth, vhost, physical eth, etc.), I don't think
it is a good way to do GSO support in OVS module, because we can't know
the final output port at this point, if the final output port is
VxLAN-gpe port, it will still face GSO issue, but I didn't see vxlan
module handles this, maybe udp tunnel did this. I think a NSH packet can
be split into two packets, one has NSH header, another one doesn't, so I'm not sure how vxlan module can avoid this situation.

For the second case, we can add a nsh GSO module in net/nsh/nsh_gso.c (as MPLS did in net/mpls/mpls_gso.c), that is the best way to handle this, what do you
think about it?
