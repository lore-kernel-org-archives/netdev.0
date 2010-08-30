From: Simon Horman <horms@verge.net.au>
Subject: [rfc] Merging the Open vSwitch datapath
Date: Mon, 30 Aug 2010 15:27:55 +0900
Message-ID: <20100830062755.GA22396@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesse Gross <jesse@nicira.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Chris Wright <chrisw@sous-sol.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Arnd Bergmann <arnd@arndb.de>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:57152 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752100Ab0H3G2A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Aug 2010 02:28:00 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I am looking to submit the Open vSwitch datapath for merging into the
kernel.  To this end I have posted a preliminary round of patches to the
dev@openvswitch.org mailing list (unfortunately the online archive seems
incomplete). It seems to me that I am now at or close to the point where
the patches can be posted to netdev. However, I have a few questions.

1) The current patches place the datapath in drivers/staging/ovs-datapath.
   It has been proposed that net/openvswitch would be a better location.
   What is the feeling of netdev on this?

   In a similar vein. Open vSwitch has some headers that are shared
   with user-space. Is include/net/openvswitch an acceptable location
   for those headers?

2) The code could do with some cleaning up. The current todo list
   includes the following items.

   * Use pr_*
   * Remove trailing whitespace and other formatting fixes
   * Stephen Hemminger would like make_writable() removed in favour
     of using skb_cow_data() or made generic.
     http://openvswitch.org/pipermail/dev_openvswitch.org/2010-August/002993.html
   * Removal of compatibility code
   * Possible use of netlink for user-space interface
   * Network namespace support

   While the last two items seem to be post-merge material to me.
   I am wondering if it is ok to handle the other items post-merge too.
   As the person doing the merge, this would make my life a lot easier
   but I'm unclear if it is an acceptable approach or not.


About Open vSwitch:

   (Text by Jesse Gross)

   Open vSwitch is a multilayer Ethernet switch targeted at virtualized
   environments.  In addition to supporting a variety of features
   expected in a traditional hardware switch, it enables fine-grained
   programmatic extension and control through the OpenFlow protocol.
   This control is useful in a wide variety of applications but is
   particularly important in multi-server virtualization deployments,
   which are often characterized by highly dynamic endpoints and the need
   to maintain logical abstractions for multiple tenants.

   The Open vSwitch datapath provides an in-kernel fast path for packet
   forwarding.  It is complemented by a userspace daemon, ovs-vswitchd,
   which is able to accept configuration from a variety of sources and
   translate it into packet processing rules.


