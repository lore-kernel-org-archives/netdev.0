From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next v4] openvswitch: enable NSH support
Date: Wed, 23 Aug 2017 09:26:24 +0200
Message-ID: <20170823092624.683f5487@griffin>
References: <1503041071-68753-1-git-send-email-yi.y.yang@intel.com>
        <20170818152601.3760aaec@griffin>
        <20170821061109.GA72656@cran64.bj.intel.com>
        <20170821101925.3f9b36a1@griffin>
        <20170821083900.GA74649@cran64.bj.intel.com>
        <20170821111854.42dece9f@griffin>
        <20170821091541.GA75219@cran64.bj.intel.com>
        <20170821114713.7c6ebb9a@griffin>
        <20170822093825.GA94865@cran64.bj.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "dev@openvswitch.org" <dev@openvswitch.org>,
        "blp@ovn.org" <blp@ovn.org>, "e@erig.me" <e@erig.me>,
        "jan.scheurich@ericsson.com" <jan.scheurich@ericsson.com>
To: "Yang, Yi" <yi.y.yang@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33354 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753474AbdHWH03 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 23 Aug 2017 03:26:29 -0400
In-Reply-To: <20170822093825.GA94865@cran64.bj.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 22 Aug 2017 17:38:26 +0800, Yang, Yi wrote:
> I checked GSO support code, we have two cases to handle, one case is to
> output NSH packet to VxLAN-gpe port, the other case is to output NSH packet
> to Ethernet port (tap, veth, vhost, physical eth, etc.), I don't think
> it is a good way to do GSO support in OVS module, because we can't know
> the final output port at this point, if the final output port is
> VxLAN-gpe port, it will still face GSO issue, but I didn't see vxlan
> module handles this, maybe udp tunnel did this. I think a NSH packet can
> be split into two packets, one has NSH header, another one doesn't,
> so I'm not sure how vxlan module can avoid this situation.

As I said before, by either implementing GSO support for NSH or by
segmenting in software before pushing the NSH header. In the first
case, the packet will be software segmented before being pushed to the
hardware, in the second case, it will be software segmented before
pushing the NSH header.

> For the second case, we can add a nsh GSO module in net/nsh/nsh_gso.c
> (as MPLS did in net/mpls/mpls_gso.c), that is the best way to handle
> this, what do you think about it?

Yes, that's one of the two options that we've been talking about. It's
the better and the more efficient one.

 Jiri
