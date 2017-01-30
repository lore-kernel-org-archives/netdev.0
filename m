From: Andreas Schultz <aschultz@tpip.net>
Subject: [PATCH net-next v2 0/6] gtp: misc improvements
Date: Mon, 30 Jan 2017 17:37:07 +0100
Message-ID: <20170130163713.17524-1-aschultz@tpip.net>
Cc: netdev@vger.kernel.org, Harald Welte <laforge@gnumonks.org>,
        Lionel Gauthier <Lionel.Gauthier@eurecom.fr>,
        openbsc@lists.osmocom.org
To: Pablo Neira <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpip.net ([92.43.49.48]:39629 "EHLO mail.tpip.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932409AbdA3QhT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 30 Jan 2017 11:37:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Pablo,

Resent as v2, because I forgot the net-next target. Sorry for noise,
I promise I won't forget it again.

This series lays the groundwork for removing the socket references from
the GTP netdevice by removing duplicate code and simplifying the logic on
some code paths.

It slighly changes the GTP genl API by making the socket parameters optional
(though one of them is still required).

The removal of the socket references will break the 1:1 releation between
GTP netdevice and GTP socket that prevents us to support multiple VRFs with
overlaping IP addresse spaces attached to the same GTP socket (needed for
multi APN support).

Regards
Andreas


Andreas Schultz (6):
  gtp: make GTP sockets in gtp_newlink optional
  gtp: merge gtp_get_net and gtp_genl_find_dev
  gtp: unify genl_find_pdp and prepare for per socket lookup
  gtp: consolidate pdp context destruction into helper
  gtp: add socket to pdp context
  gtp: consolidate gtp socket rx path

 drivers/net/gtp.c | 564 +++++++++++++++++++++++++++---------------------------
 1 file changed, 280 insertions(+), 284 deletions(-)

-- 
2.10.2
