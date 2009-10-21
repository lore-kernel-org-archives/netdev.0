From: Gilad Ben-Yossef <gilad@codefidence.com>
Subject: [PATCH v2 0/8] Per route TCP options
Date: Wed, 21 Oct 2009 10:56:53 +0200
Message-ID: <1256115421-12714-1-git-send-email-gilad@codefidence.com>
Cc: ori@comsleep.com, Gilad Ben-Yossef <gilad@codefidence.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenbox.codefidence.com ([92.48.73.16]:39380 "EHLO
	xenbox.codefidence.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753266AbZJUI46 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2009 04:56:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Turn the global sysctls allowing disabling of TCP SACK, DSCAK,
time stamp and window scale into per route entry feature options,
laying the ground to future removal of the relevant global sysctls.

You really only want to disable SACK, DSACK, time stamp or window
scale if you've got a piece of broken networking equipment somewhere 
as a stop gap until you can bring a big enough hammer to deal with
the broken network equipment. It doesn't make sense to "punish" the
entire connections going through the machine to destinations not 
related to the broken equipment.

This is doubly true when you're dealing with network containers
used to isolate several virtual domains.

Per route options implemented in free bits in the features route
entry property, which in some cases were reserved by name for these
options, so this does not inflate any structure and I expect that
when the apropriate global sysctls will be removed the overall code
base will be smaller.

Tested on x86 using Qemu/KVM.  

Will send the matching patch to iproute2 if/when this is ACKed or
if someone wants to test this.

Patchset based on original work by Ori Finkelman and Yony Amit 
from ComSleep Ltd.

Gilad Ben-Yossef (8):
  Only parse time stamp TCP option in time wait sock
  Allow tcp_parse_options to consult dst entry
  Infrastructure for querying route entry features
  Add the no SACK route option feature
  Allow disabling TCP timestamp options per route
  Allow to turn off TCP window scale opt per route
  Allow disabling of DSACK TCP option per route
  Document future removal of sysctl_tcp_* options

 Documentation/feature-removal-schedule.txt |   12 ++++++++++++
 include/linux/rtnetlink.h                  |    6 ++++--
 include/net/dst.h                          |    8 +++++++-
 include/net/tcp.h                          |    3 ++-
 net/ipv4/syncookies.c                      |   27 ++++++++++++++-------------
 net/ipv4/tcp_input.c                       |   26 ++++++++++++++++++--------
 net/ipv4/tcp_ipv4.c                        |   19 ++++++++++---------
 net/ipv4/tcp_minisocks.c                   |    8 +++++---
 net/ipv4/tcp_output.c                      |   18 +++++++++++++-----
 net/ipv6/syncookies.c                      |   28 +++++++++++++++-------------
 net/ipv6/tcp_ipv6.c                        |    3 ++-
 11 files changed, 102 insertions(+), 56 deletions(-)

