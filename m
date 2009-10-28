From: Gilad Ben-Yossef <gilad@codefidence.com>
Subject: [PATCHv4 0/7] Per route TCP options support kill switches
Date: Wed, 28 Oct 2009 16:15:20 +0200
Message-ID: <1256739327-11576-1-git-send-email-gilad@codefidence.com>
Cc: ori@comsleep.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenbox.codefidence.com ([92.48.73.16]:58543 "EHLO
	xenbox.codefidence.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753901AbZJ1OP2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2009 10:15:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow selectively turning off support for specific TCP options
on a per route basis.

One normally want to disable SACK, DSACK, time stamp or window
scale if one got a piece of broken networking equipment somewhere
as a stop gap until you can bring a big enough hammer to deal with
the broken network equipment. It doesn't make sense to "punish" the
entire connections going through the machine to destinations not
related to the broken equipment.

This is doubly true when one is dealing with network containers
used to isolate several virtual domains.

Per route options implemented in free bits in the features route
entry property, which in some cases were reserved by name for these
options, so this does not inflate any structure.

Global sysctls for these options are still preserved and retain 
the exact original meaning (e.g. you have to have both the global 
sysctl turned on and not turn off the TCP option parsing in the
specific route to have it proccessed).

It is not possible to turn off globally an option but turn it on
per route, so as to not subtly change the meaning of current
establish sysctls (and this is a rare need anyway).

Tested on x86 using Qemu/KVM.

Working but crude matching patch to iproute2 sent earlier to the list.

Patchset based on original work by Ori Finkelman and Yony Amit
from ComSleep Ltd.

The author wishes to thank Eric Dumazaet, William Allen Simpson, 
Bill Fink and Ilpo Jarvinen for their feedback.


Gilad Ben-Yossef (7):
  Only parse time stamp TCP option in time wait sock
  Allow tcp_parse_options to consult dst entry
  Add dst_feature to query route entry features
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
 net/ipv4/tcp_minisocks.c  |    9 ++++++---
 net/ipv4/tcp_output.c     |   18 +++++++++++++-----
 net/ipv6/syncookies.c     |   28 +++++++++++++++-------------
 net/ipv6/tcp_ipv6.c       |    3 ++-
 10 files changed, 93 insertions(+), 56 deletions(-)

