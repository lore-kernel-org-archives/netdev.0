From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH iproute2 0/4] improve initialization of genl handle
Date: Tue, 16 Aug 2016 16:26:54 +0200
Message-ID: <cover.1471356460.git.sd@queasysnail.net>
Cc: Phil Sutter <phil@nwl.cc>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Sabrina Dubroca <sd@queasysnail.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41260 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751455AbcHPO1O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Aug 2016 10:27:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset fixes several issues for users of genetlink:

 - Duplicated code for initialization of a genl handle.
   All users of genl must open a socket and resolve the family, and
   use the same code to do that.
   Solution: add a library function.

 - genl family resolution fails when the module that handles this
   family is not loaded yet.
   This means that if we try to initialize the genl handle early in
   handling the command, we cannot display usage, because we fail hard
   when trying to resolve the genl family.
   Solution: move the genl handle initialization after handling the
   `ip * help` case.

Sabrina Dubroca (4):
  libgenl: introduce genl_init_handle
  macsec: show usage even if the module is not available
  fou: show usage even if the module is not available
  ila: show usage even if the module is not available

 include/libgenl.h |  2 ++
 ip/ipfou.c        | 20 ++++++--------------
 ip/ipila.c        | 19 ++++++-------------
 ip/ipl2tp.c       | 12 ++----------
 ip/ipmacsec.c     | 20 +++-----------------
 ip/tcp_metrics.c  | 14 +++-----------
 lib/libgenl.c     | 17 +++++++++++++++++
 7 files changed, 39 insertions(+), 65 deletions(-)

-- 
2.9.3
