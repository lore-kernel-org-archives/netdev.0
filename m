From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next 0/4] nsh: headers, GSO
Date: Wed, 30 Aug 2017 09:20:40 +0200
Message-ID: <20170830092040.61e5f09b@griffin>
References: <cover.1503948295.git.jbenc@redhat.com>
        <20170829.151707.1911972805135395713.davem@davemloft.net>
        <20170830052303.GA109175@cran64.bj.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "e@erig.me" <e@erig.me>,
        "jan.scheurich@ericsson.com" <jan.scheurich@ericsson.com>,
        "blp@ovn.org" <blp@ovn.org>
To: "Yang, Yi" <yi.y.yang@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60070 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751186AbdH3HUo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 30 Aug 2017 03:20:44 -0400
In-Reply-To: <20170830052303.GA109175@cran64.bj.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 30 Aug 2017 13:23:04 +0800, Yang, Yi wrote:
> David has merged your NSH GSO series, do you have one more patch series
> to fix VxLAN-gpe+NSH GSO issue? I think we still need do something in
> skb_udp_tunnel_segment in net/ipv4/udp_offload.c to support
> VxLAN-gpe+NSH GSO.

This should work as is.

The only issue is VXLAN-GPE offloading where not all drivers distinguish
VXLAN from VXLAN-GPE in ndo_features_check, while I'm not sure their
firmware actually supports VXLAN-GPE. We don't make it easy for the
drivers to distinguish those two, the only way is to examine the
headers. We could do better here but that's for future improvement.

> I'll post new OVS NSH kernel datapath patch series if NSH GSO is done.

Please do. Note that it's important to ensure that whenever there's a
NSH header added, the nsh module gets loaded. The easiest way is to
factor out code that will be shared by the NSH tc action into nsh.c.
This would have to be done anyway so let's do it right away.

 Jiri
