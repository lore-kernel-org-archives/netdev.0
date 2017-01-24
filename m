From: Andreas Schultz <aschultz@tpip.net>
Subject: [PATCH v2 00/18] gtp: fixes and support multiple VRF's per GTP socket
Date: Tue, 24 Jan 2017 16:28:30 +0100
Message-ID: <20170124152848.6120-1-aschultz@tpip.net>
Cc: netdev@vger.kernel.org,
        Lionel Gauthier <Lionel.Gauthier@eurecom.fr>,
        openbsc@lists.osmocom.org, Harald Welte <laforge@gnumonks.org>
To: Pablo Neira <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpip.net ([92.43.49.48]:43643 "EHLO mail.tpip.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751058AbdAXP2z (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 24 Jan 2017 10:28:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current linking of GTP network devices and GTP enabled sockets means that
we can not have multiple VRF's per GTP socket. This series seperates the
sockets from network device, makes sockets attached to GTP network device
optional and adds a API function to enable GTP encapsulation on socket
without having to create a new GTP device.

It is still possible to use the old API. The network device attached socket is
then used when no socket is specified on PDP context creation.

During that work some smaller problems where found and fixes for them are
included.

v2 changes:

 * the socket that is hold by the pdp context has to be release in a rcu
   callback. Otherwise a stray GTP rx could end uo with an invalid socket.
 * accessing the skb->sk field in gtp_rx is invalid, that field has no
   been populated at that point
 * add dst_cache to speed up the routing

Regards
Andreas
