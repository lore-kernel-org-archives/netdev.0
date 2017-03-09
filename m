From: Andreas Schultz <aschultz@tpip.net>
Subject: [PATCH net-next v5 0/7] gtp: misc improvements
Date: Thu,  9 Mar 2017 17:42:55 +0100
Message-ID: <20170309164302.13550-1-aschultz@tpip.net>
Cc: osmocom-net-gprs@lists.osmocom.org, netdev <netdev@vger.kernel.org>
To: Harald Welte <laforge@gnumonks.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpip.net ([92.43.49.48]:52755 "EHLO mail.tpip.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932719AbdCIQn3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 9 Mar 2017 11:43:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Pablo,

This is a resent of last series that missed the merge window. There
are no changes compared to v4.

v4: Compared to v3 it contains mostly smallish naming and spelling fixes.
It also drops the documentation patch, Harald did a better job with the
documentation and the some things I described do not yet match the implementation.
I'll readd the relevant parts with a follow up series.

This series lays the groundwork for removing the socket references from
the GTP netdevice by removing duplicate code and simplifying the logic on
some code paths.

It slighly changes the GTP genl API by making the socket parameters optional
(though one of them is still required).

The removal of the socket references will break the 1:1 releation between
GTP netdevice and GTP socket that prevents us to support multiple VRFs with
overlapping IP addresse spaces attached to the same GTP-U entity (needed for
multi APN support, coming a follow up series).

Pablo found a socket hold problem in v2. In order to solve that I had to
switch the socket references from the struct socket to the internal
struct sock. This should have no functionl impact, but we can now hang
on to the reference without blocking user space from closing the GTP socket.

v4->v5:
 * resent for new merge window
v3->v4:
 * drop the documentation patch
 * spelling fixes
 * pass nlattr instead of genl_info into gtp_find_dev,
   makes the code slightly more compact and readable
v2->v3:
 * add documentation to explain the goal of all these changes
 * incorporate review comments
 * switch from struct socket to struct sock

Regards
Andreas
