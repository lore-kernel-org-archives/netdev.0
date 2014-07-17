From: Veaceslav Falico <vfalico@gmail.com>
Subject: [PATCH net-next 0/2] net: print net_device name/state more often
Date: Thu, 17 Jul 2014 13:28:09 +0200
Message-ID: <1405596491-5881-1-git-send-email-vfalico@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Jason Baron <jbaron@akamai.com>,
	Eric Dumazet <edumazet@google.com>,
	Vlad Yasevich <vyasevic@redhat.com>,
	stephen hemminger <stephen@networkplumber.org>,
	Jerry Chu <hkchu@google.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Veaceslav Falico <vfalico@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33629 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755856AbaGQLcs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jul 2014 07:32:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Currently we use net_device->name only if it's the NETREG_REGISTERED
reg_state, otherwise we return "(unregistered device)".

However, we always populate net_device->name on creation, so it's always
available to us for use. The only caveat is that we might have a name like
"eth%d", in which case we cannot use it as it might change in the future.

Also, the net_device might not be NETREG_UNREGISTERED when the function is
called (_UNINITIALIZED, _UNREGISTERING, _RELEASED, _DUMMY), so it's
misleading.

So, a better way would be to always return the dev->name in netdev_name(),
unless it's in the form of "eth%d", then return "unnamed net_device". This
way we'll always return the name in NETREG_REGISTERED reg_state, and also
return it in other states, when possible.

Also, to be more verbose on non-NETREG_REGISTERED states, add a function
netdev_reg_state(), which returns a string describing the state, and use it
in netdev_printk()-related functions. If the dev is in NETREG_REGISTERED
state then a void string is regurned and, thus, nothing changes.

After these two patches we'll have the same behaviour in the usual cases,
and more verbose in non-standardad/buggy ones.

CC: "David S. Miller" <davem@davemloft.net>
CC: Jason Baron <jbaron@akamai.com>
CC: Eric Dumazet <edumazet@google.com>
CC: Vlad Yasevich <vyasevic@redhat.com>
CC: stephen hemminger <stephen@networkplumber.org>
CC: Jerry Chu <hkchu@google.com>
CC: Ben Hutchings <bhutchings@solarflare.com>
Signed-off-by: Veaceslav Falico <vfalico@gmail.com>

---
 include/linux/netdevice.h | 21 ++++++++++++++++++---
 lib/dynamic_debug.c       |  8 +++++---
 net/core/dev.c            |  8 +++++---
 3 files changed, 28 insertions(+), 9 deletions(-)
