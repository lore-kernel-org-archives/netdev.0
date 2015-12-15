From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next v2 0/2] net: Allow accepted sockets to be bound to l3mdev domain
Date: Tue, 15 Dec 2015 09:18:10 -0800
Message-ID: <1450199892-18201-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:35456 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965325AbbLORSV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2015 12:18:21 -0500
Received: by mail-pa0-f41.google.com with SMTP id hk6so7863092pad.2
        for <netdev@vger.kernel.org>; Tue, 15 Dec 2015 09:18:21 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow accepted sockets to derive their sk_bound_dev_if setting from the
l3mdev domain in which the packets originated. This version adds a sysctl
to control whether the setting is inherited, making the functionality
similar to sk_mark and its sysctl_tcp_fwmark_accept setting.

This effectively allow a process to have a "VRF-global" listen socket,
with child sockets bound to the VRF device in which the packet originated.
A similar behavior can be achieved using sk_mark, but a solution using marks
is incomplete as it does not handle duplicate addresses in different L3
domains/VRFs. Allowing sockets to inherit the sk_bound_dev_if from l3mdev
domain provides a complete solution.

v2
- Wrap the sk_bound_dev_if inheritance behavior in a new sysctl that
  defaults to disabled so a user has to opt-in

David Ahern (2):
  net: l3mdev: Add master device lookup by index
  net: Allow accepted sockets to be bound to l3mdev domain

 Documentation/networking/ip-sysctl.txt |  7 +++++++
 include/net/inet_sock.h                | 12 ++++++++++++
 include/net/l3mdev.h                   | 23 +++++++++++++++++++++++
 include/net/netns/ipv4.h               |  1 +
 net/ipv4/syncookies.c                  |  4 ++--
 net/ipv4/sysctl_net_ipv4.c             |  9 +++++++++
 net/ipv4/tcp_input.c                   |  2 +-
 net/ipv4/tcp_ipv4.c                    |  1 +
 net/ipv6/syncookies.c                  |  4 ++--
 9 files changed, 58 insertions(+), 5 deletions(-)

-- 
1.9.1
