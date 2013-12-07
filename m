From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 0/5] neigh: respect default parms values
Date: Sat,  7 Dec 2013 19:26:52 +0100
Message-ID: <1386440817-7846-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net,
	hannes@stressinduktion.org, bcrl@kvack.org, gaofeng@cn.fujitsu.com,
	joe@perches.com, herbert@gondor.apana.org.au
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f47.google.com ([74.125.83.47]:45739 "EHLO
	mail-ee0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753491Ab3LGS1B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Dec 2013 13:27:01 -0500
Received: by mail-ee0-f47.google.com with SMTP id e51so831642eek.20
        for <netdev@vger.kernel.org>; Sat, 07 Dec 2013 10:27:00 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a long standing regression. But since the patchset is bigger and
the regression happened in 2007, I'm proposing this to net-next instead.

Basically the problem is that if user wants to use /etc/sysctl.conf to specify
default values of neigh related params, he is not able to do that.

The reason is that the default values are copied to dev instance right after
netdev is registered. And that is way to early. The original behaviour
for ipv4 was that this happened after first address was assigned to device.
For ipv6 this was apparently from the very beginning.

So this patchset basically reverts the behaviour back to what it was in 2007 for
ipv4 and changes the behaviour for ipv6 so they are both the same.

v1->v2:
- use neigh_parms->tbl->family as suggested by davem

Jiri Pirko (5):
  neigh: convert parms to an array
  neigh: wrap proc dointvec functions
  neigh: use tbl->family to distinguish ipv4 from ipv6
  neigh: restore old behaviour of default parms values
  neigh: ipv6: respect default values set before an address is assigned
    to device

 include/linux/inetdevice.h |   7 +
 include/net/addrconf.h     |   7 +
 include/net/neighbour.h    |  77 ++++++--
 net/802/hippi.c            |   4 +-
 net/core/neighbour.c       | 451 +++++++++++++++++++++++++--------------------
 net/decnet/dn_neigh.c      |  28 +--
 net/ipv4/arp.c             |  35 ++--
 net/ipv4/devinet.c         |   4 +-
 net/ipv4/ipmr.c            |   2 +
 net/ipv6/addrconf.c        |  16 +-
 net/ipv6/ndisc.c           |  55 +++---
 11 files changed, 414 insertions(+), 272 deletions(-)

-- 
1.8.3.1
