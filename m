From: Gilad Ben-Yossef <gilad@codefidence.com>
Subject: [PATCH v3 0/7] Per route TCP options
Date: Mon, 26 Oct 2009 10:06:26 +0200
Message-ID: <1256544393-12450-1-git-send-email-gilad@codefidence.com>
Cc: ori@comsleep.com, Gilad Ben-Yossef <gilad@codefidence.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenbox.codefidence.com ([92.48.73.16]:47174 "EHLO
	xenbox.codefidence.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754990AbZJZIGb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2009 04:06:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Third iteration of patch to allow disablng of TCP SACK, DSCAK, 
time stamp and window scale TCP options on a per route basis, now
with 100% less remote DoS opportunities (thank you Ilpo for 
spotting it ;-)

You usualy want to disable SACK, DSACK, time stamp or window
scale if you've got a piece of broken networking equipment somewhere 
as a stop gap until you can bring a big enough hammer to deal with
the broken network equipment. It doesn't make sense to "punish" the
entire connections going through the machine to destinations not 
related to the broken equipment.

This is doubly true when you're dealing with network containers
used to isolate several virtual domains.

Per route options implemented in free bits in the features route
entry property, which in some cases were reserved by name for these
options, so this does not inflate any structure.

Global sysctl based kill switches for these options are still
preserved, as some people seems to want them, so behaviour
is default to on, unless switched off either globaly or on
per route basis.

Tested on x86 using Qemu/KVM.  

Working but crude matching patch to iproute2 sent earlier to the list.

Patchset based on original work by Ori Finkelman and Yony Amit 
from ComSleep Ltd.

Gilad Ben-Yossef (7):
  Only parse time stamp TCP option in time wait sock
  Allow tcp_parse_options to consult dst entry
  Infrastructure for querying route entry features
  Add the no SACK route option feature
  Allow disabling TCP timestamp options per route
  Allow to turn off TCP window scale opt per route
  Allow disabling of DSACK TCP option per route

 include/linux/rtnetlink.h |    6 ++++--
 include/net/dst.h         |    8 +++++++-
 include/net/tcp.h         |    3 ++-
 net/ipv4/syncookies.c     |   27 ++++++++++++++-------------
 net/ipv4/tcp_input.c      |   26 ++++++++++++++++++--------
 net/ipv4/tcp_ipv4.c       |   21 ++++++++++++---------
 net/ipv4/tcp_minisocks.c  |    8 +++++---
 net/ipv4/tcp_output.c     |   18 +++++++++++++-----
 net/ipv6/syncookies.c     |   28 +++++++++++++++-------------
 net/ipv6/tcp_ipv6.c       |    3 ++-
 10 files changed, 92 insertions(+), 56 deletions(-)

