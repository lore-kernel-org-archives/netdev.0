From: Tom Parkin <tparkin@katalix.com>
Subject: [PATCH 0/4] l2tp: fix up network namespace use in l2tp_core
Date: Wed,  9 Jan 2013 18:36:19 +0000
Message-ID: <1357756583-22535-1-git-send-email-tparkin@katalix.com>
Cc: Tom Parkin <tparkin@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:55327 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932134Ab3AISge (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jan 2013 13:36:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset addresses network namespace issues in l2tp_core as previously
raised on netdev[1].

There is further work to be done to bring namespace support to the rest of
l2tp -- this will be addressed in a further patchset.

I've tested these changes using a stress script based around iproute2's netns
command.  Test platforms include i386, x86_64, and armv6l, running on
single-core and SMP platforms, and with/without preemption enabled.

[1].
http://www.spinics.net/lists/netdev/msg214776.html
http://www.spinics.net/lists/netdev/msg212234.html

Tom Parkin (4):
  l2tp: set netnsok flag for netlink messages
  l2tp: prevent tunnel creation on netns mismatch
  l2tp: don't pin network namespaces with tunnel sockets
  l2tp: clear tunnel socket field as soon as we release it

 net/l2tp/l2tp_core.c    |  101 +++++++++++++++++++++++++++++++----------------
 net/l2tp/l2tp_netlink.c |    1 +
 2 files changed, 68 insertions(+), 34 deletions(-)

-- 
1.7.9.5
