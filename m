From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCHv3 0/4] macvlan: add vepa and bridge mode
Date: Thu, 26 Nov 2009 17:07:07 +0100
Message-ID: <1259251631-11617-1-git-send-email-arnd@arndb.de>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Anna Fischer <anna.fischer@hp.com>,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	Mark Smith <lk-netdev@lk-netdev.nosense.org>,
	Gerhard Stenzel <gerhard.stenzel@de.ibm.com>,
	Arnd Bergmann <arnd@arndb.de>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Jens Osterkamp <jens@linux.vnet.ibm.com>,
	Patrick Mullaney <pmullaney@novell.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.9]:54392 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755902AbZKZQHP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Nov 2009 11:07:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Not many changes this time, just integrated a bug fix
and all the coding style feedback from Eric Dumazet
and Patrick McHardy.

I'll keep the patch for network namespaces on the tx
path out of this series for now, because the discussion
is still ongoing and it addresses an unrelated issue.

---

Version 2 description:
The patch to iproute2 has not changed, so I'm not including
it this time. Patch 4/4 (the netlink interface) is basically
unchanged as well but included for completeness.

The other changes have moved forward a bit, to the point where
I find them a lot cleaner and am more confident in the code
being ready for inclusion. The implementation hardly resembles
Erics original patch now, so I've dropped his signed-off-by.

Please take a look and ack if you are happy so we can get it
into 2.6.33.

---

Version 1 description:
This is based on an earlier patch from Eric Biederman adding
forwarding between macvlans. I extended his approach to
allow the administrator to choose the mode for each macvlan,
and to implement a functional VEPA between macvlan.

Still missing from this is support for communication between
the lower device that the macvlans are based on. This would
be extremely useful but as others have found out before me
requires significant changes not only to macvlan but also
to the common transmit path.

I've tested VEPA operation with the hairpin support
added to the bridge driver by Anna Fischer.

---
Arnd Bergmann (4):
  veth: move loopback logic to common location
  macvlan: cleanup rx statistics
  macvlan: implement bridge, VEPA and private mode
  macvlan: export macvlan mode through netlink

 drivers/net/macvlan.c     |  188 +++++++++++++++++++++++++++++++++++++--------
 drivers/net/veth.c        |   17 +----
 include/linux/if_link.h   |   15 ++++
 include/linux/netdevice.h |    2 +
 net/core/dev.c            |   40 ++++++++++
 5 files changed, 214 insertions(+), 48 deletions(-)

