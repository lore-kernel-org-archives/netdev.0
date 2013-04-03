From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH RFC 0/5] tipc: add support for TIPC over InfiniBand
Date: Wed,  3 Apr 2013 14:43:25 +0200
Message-ID: <1364993010-15515-1-git-send-email-kaber@trash.net>
Cc: allan.stephens@windriver.com, netdev@vger.kernel.org,
	roland@kernel.org, sean.hefty@intel.com, hal.rosenstock@gmail.com,
	linux-rdma@vger.kernel.org
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:48246 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759723Ab3DCMyB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Apr 2013 08:54:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following patchset adds support for running TIPC over InfiniBand.
The patchset consists of three parts (+ a minor fix for the ethernet media
type):

- Preparation: removal of an the unused str2addr callback and move of the
  bcast_addr from struct tipc_media to struct tipc_bearer. This is necessary
  because InfiniBand doesn't have a fixed broadcast address like ethernet,
  so it needs to be initialized with the device's broadcast address when
  the bearer is enabled

- Introduction of a TIPC InfiniBand media type. A new media type is needed
  to deal with the different address sizes

- Support for ETH_P_TIPC in IPoIB

The last patch is something I'd like to discuss, I realize that this diverges
from the IPoIB specification, however the alternative would be to implement
something which would be pretty much identical to IPoIB with the only
difference of handling a different ethertype in the xmit function.

In fact I'd like to propose to remove all higher layer protocol knowledge
from IPoIB except for ARP and RARP, which need special treatment. With the
recent patch to manage neighbour entries in IPoIB itself, no further knowledge
of higher layer protocols is required.

The patchset is based on net-next.

Comments welcome.
