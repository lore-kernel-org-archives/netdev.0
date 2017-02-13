From: Andreas Schultz <aschultz@tpip.net>
Subject: [PATCH net-next v3 0/8] gtp: misc improvements
Date: Mon, 13 Feb 2017 16:36:16 +0100
Message-ID: <20170213153624.14170-1-aschultz@tpip.net>
Cc: netdev@vger.kernel.org, Harald Welte <laforge@gnumonks.org>,
        Lionel Gauthier <Lionel.Gauthier@eurecom.fr>,
        osmocom-net-gprs@lists.osmocom.org, Jonas Bonn <jonas@southpole.se>
To: Pablo Neira <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpip.net ([92.43.49.48]:58274 "EHLO mail.tpip.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753680AbdBMPgf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 13 Feb 2017 10:36:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Pablo,

This is v3 of the GTP improvements.

This series lays the groundwork for removing the socket references from
the GTP netdevice by removing duplicate code and simplifying the logic on
some code paths.

It slighly changes the GTP genl API by making the socket parameters optional
(though one of them is still required).

The removal of the socket references will break the 1:1 releation between
GTP netdevice and GTP socket that prevents us to support multiple VRFs with
overlaping IP addresse spaces attached to the same GTP-U entity (needed for
multi APN support).

Pablo found a socket hold problem in v2. In order to solve that I had to
switch the socket references from the struct socket to the internal
struct sock. This should have no functionl impact, but we can now hang
on to the reference without blocking user space from closing the GTP socket.

There was also some length off-list conversation about why the netdevice to
socket relation needs to be changed at all. Harald did already agree to this
but Pablo had some questions. I've tried to address that with a bit of
dokumentation for the GTP module. Hopefully this will explain the need for
the change sufficiently.

This series does have conflicts with the SGSN side tunnel work done by
Jonas Bonn. The unification of the tunnel Rx code touches the same places
he changed.

v2->v3:
 * add documentation to explain the goal of all these changes
 * incorporate review comments
 * switch from struct socket to struct sock

Regards
Andreas
