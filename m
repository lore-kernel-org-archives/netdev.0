From: Patrick McHardy <kaber@trash.net>
Subject: [IPROUTE 00/02]: rtnl_link support
Date: Wed, 13 Jun 2007 19:02:32 +0200 (MEST)
Message-ID: <20070613170229.8318.75488.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: shemminger@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36208 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758168AbXFMRCd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2007 13:02:33 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Stephen,

these patches add support for the rtnl_link stuff and VLAN configuration
to iproute. Since the old link configuration was entirely ioctl based and
mixing the two would be really ugly, this patch keeps the old ioctl stuff
guarded by an ifdef (defaults to enabled) and probes for support for
using RTM_NEWLINK. Tested to work properly on both old and patched kernel.

I've added a new -d[etail] flag to ip, the driver specific things are only
printed when it is specified. I did this mainly because I'm not sure how
careful we want to be not to confuse people using sed/awk/... on iproute
output. I would prefer to have the information always shown, but I'll
leave that decision up to you.

Changes since the last post:

- Only call link argument parsing function if arguments are present
- Support xstats dumping
- Add sanitized if_vlan.h file for VLAN flag definition
- Support setting/changing VLAN flags

Please apply, thanks.


 include/linux/if_link.h |   47 +++++++
 include/linux/if_vlan.h |   61 +++++++++
 ip/Makefile             |    4 
 ip/ip.c                 |    5 
 ip/ip_common.h          |   15 ++
 ip/ipaddress.c          |   39 ++++++
 ip/iplink.c             |  311 +++++++++++++++++++++++++++++++++++++++++++++++-
 ip/iplink_vlan.c        |  184 ++++++++++++++++++++++++++++
 8 files changed, 663 insertions(+), 3 deletions(-)

Patrick McHardy (2):
      [IPROUTE]: iplink: use netlink for link configuration
      [IPROUTE]: VLAN support
