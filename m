From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 0/2] ip-address: fix type list inconsistencies
Date: Tue, 28 Jun 2016 15:07:15 +0200
Message-ID: <1467119237-12544-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:47044 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752428AbcF1NHs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Jun 2016 09:07:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The basic problem was differences in type list reported by help output
and stated in man page.

I decided to tackle the problem from both sides:
a) Make sure 'ip addr show' supports matching on all types reported.
b) Add missing types in either list.

This is still rather best-effort, actually things are quite messed up:
- Lists are not sorted, it's easy to miss something.
- The type list is duplicated four times as ip-link help and man page
  contain it, too.
- The kernel supports more types than listed here.
- We can't add but match on all types the kernel supports.

Phil Sutter (2):
  ip-address: Support filtering by slave type, too
  ip-address: Align type list in help and man page

 ip/ipaddress.c           | 58 +++++++++++++++++++++++++++---------------------
 man/man8/ip-address.8.in |  3 +++
 2 files changed, 36 insertions(+), 25 deletions(-)

-- 
2.8.2
