From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 0/2] Check MAC address length when changing it
Date: Thu, 16 Jun 2016 16:19:38 +0200
Message-ID: <1466086780-5613-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:54726 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754575AbcFPOTy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jun 2016 10:19:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Due to minimal checking in kernel space, MAC address setting was
problematic in multiple ways:

- Setting an overly long MAC address was accepted and the extra parts
  simply ignored.

- Setting an overly short MAC address for VFs was accepted and the
  missing part filled with random garbage.

While patch 1 makes sure that in the second case above missing parts are
padded with zero, patch 2 implements a real solution for both by
comparing new and old address lengths prior to accepting the input. For
VFs it is simply assumed that the length must match that of the PF's
address.

Phil Sutter (2):
  iplink: Add missing variable initialization
  iplink: Check address length via netlink

 ip/iplink.c | 54 +++++++++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 51 insertions(+), 3 deletions(-)

-- 
2.8.2
