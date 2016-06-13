From: Andrey Vagin <avagin@openvz.org>
Subject: [PATCH net-next 0/3] [RFC]  netlink: prepare to dump and restore data from a receive queue
Date: Sun, 12 Jun 2016 23:07:18 -0700
Message-ID: <1465798041-6783-1-git-send-email-avagin@openvz.org>
Cc: criu@openvz.org, Andrey Vagin <avagin@openvz.org>,
	Pavel Emelyanov <xemul@virtuozzo.com>,
	"David S. Miller" <davem@davemloft.net>,
	Ken-ichirou MATSUZAWA <chamaken@gmail.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Florian Westphal <fw@strlen.de>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Herrmann <dh.herrmann@gmail.com>,
	Christophe Ricard <christophe.ricard@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:32991 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932165AbcFMGI3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 02:08:29 -0400
Received: by mail-pf0-f196.google.com with SMTP id c74so9865722pfb.0
        for <netdev@vger.kernel.org>; Sun, 12 Jun 2016 23:08:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CRIU can dump queued data for unix and tcp sockets,
now it's time for netlink sockets.

Here are there questions.
* How to dump data from a receive queue
  We can set peeking offset like we do for unix sockets.

* How to restore data back to a receive queue
  I suggest to add a repair mode like we do for tcp sockets.

* When we can dump data from a receive queue.
  I think we can do this only if a socket doesn't have a running callback.

Cc: Pavel Emelyanov <xemul@virtuozzo.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Ken-ichirou MATSUZAWA <chamaken@gmail.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Florian Westphal <fw@strlen.de>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: David Herrmann <dh.herrmann@gmail.com>
Cc: Christophe Ricard <christophe.ricard@gmail.com>

Andrey Vagin (3):
  netlink: allow to set peeking offset for sockets
  netlink: add an ability to restore messages in a receive queue
  netlink/diag: report flags for netlink sockets

 include/uapi/linux/netlink.h      |  1 +
 include/uapi/linux/netlink_diag.h | 10 +++++
 net/netlink/af_netlink.c          | 82 ++++++++++++++++++++++++++-------------
 net/netlink/af_netlink.h          |  9 +++++
 net/netlink/diag.c                | 25 ++++++++++++
 5 files changed, 99 insertions(+), 28 deletions(-)

-- 
2.5.5
