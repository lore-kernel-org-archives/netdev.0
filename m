From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 0/3] macvlan: add vepa and bridge mode
Date: Tue, 17 Nov 2009 22:39:07 +0000
Message-ID: <1258497551-25959-1-git-send-email-arnd@arndb.de>
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Patrick McHardy <kaber@trash.net>,
	Patrick Mullaney <pmullaney@novell.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Edge Virtual Bridging <evb@yahoogroups.com>,
	Anna Fischer <anna.fischer@hp.com>,
	bridge@lists.linux-foundation.org,
	virtualization@linux-foundation.com,
	Jens Osterkamp <jens@linux.vnet.ibm.com>,
	Gerhard Stenzel <gerhard.stenzel@de.ibm.com>,
	Arnd Bergmann <arnd@arndb.de>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:56157 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756003AbZKQWl0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2009 17:41:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is based on an earlier patch from Eric Biederman adding
forwarding between macvlans. I extended his approach to
allow the administrator to choose the mode for each macvlan,
and to implement a functional VEPA between macvlan.

Still missing from this is support for communication between
the lower device that the macvlans are based on. This would
be extremely useful but as others have found out before me
requires significant changes not only to macvlan but also
to the common transmit path.

I've seen one panic during testing this that I still need
to track down, but it generally does what is advertised.
I've tested VEPA operation with the hairpin support
added to the bridge driver by Anna Fischer.

My current plan is to submit this for inclusion in 2.6.33
when people are happy with it and I tracked down any
remaining bugs, and possibly to do the communication with
the lower device one release later.

	Arnd <><

---

Arnd Bergmann (3):
  macvlan: implement VEPA and private mode
  macvlan: export macvlan mode through netlink
  iplink: add macvlan options for bridge mode

Eric Biederman (1):
  macvlan: Reflect macvlan packets meant for other macvlan devices

 linux/drivers/net/macvlan.c   |  170 +++++++++++++++++++++++++++++++++-----
 linux/include/linux/if_link.h |   15 +++
 2 files changed, 161 insertions(+), 24 deletions(-)

 iproute2/include/linux/if_link.h |   15 +++
 iproute2/ip/Makefile             |    3 +-
 iproute2/ip/iplink_macvlan.c     |   93 ++++++++++++++++++
 3 files changed, 110 insertions(+), 1 deletions(-)
 create mode 100644 ip/iplink_macvlan.c
