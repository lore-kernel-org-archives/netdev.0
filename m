From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Introduce support to lazy initialize mostly static keys v2
Date: Sun,  6 Oct 2013 01:20:50 +0200
Message-ID: <1381015258-7667-1-git-send-email-hannes@stressinduktion.org>
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

This series implements support for delaying the initialization of secret
keys, e.g. used for hashing, for as long as possible. This functionality
is implemented by a new macro, net_get_random_bytes.

I already used it to protect the socket hashes, the syncookie secret
(most important) and the tcp_fastopen secrets.   

Changelog:
v2) Use static_keys in net_get_random_once to have as minimal impact to
    the fast-path as possible.

Included patches:
 ipv4: split inet_ehashfn to hash functions
 ipv6: split inet6_ehashfn to hash functions
 x86/jump_label: expect default_nop if
 net: introduce new macro net_get_random_once
 inet: split syncookie keys for ipv4 and ipv6
 inet: convert inet_ehash_secret and
 tcp: switch tcp_fastopen key generation to
 net: switch net_secret key generation to

Diffstat:
 arch/x86/kernel/jump_label.c   | 25 ++++++++++++++++++-------
 include/linux/net.h            | 25 +++++++++++++++++++++++++
 include/net/inet6_hashtables.h | 29 +++++++----------------------
 include/net/inet_sock.h        | 26 ++++++--------------------
 include/net/ipv6.h             |  4 ++--
 include/net/tcp.h              |  3 +--
 net/core/secure_seq.c          | 14 ++------------
 net/core/utils.c               | 48 ++++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv4/af_inet.c             | 27 ---------------------------
 net/ipv4/inet_hashtables.c     | 25 +++++++++++++++++++++++++
 net/ipv4/syncookies.c          | 15 +++++----------
 net/ipv4/sysctl_net_ipv4.c     |  5 +++++
 net/ipv4/tcp_fastopen.c        | 27 ++++++++++++++++-----------
 net/ipv4/udp.c                 | 20 ++++++++++++++++----
 net/ipv6/af_inet6.c            |  5 -----
 net/ipv6/inet6_hashtables.c    | 34 ++++++++++++++++++++++++++++++++++
 net/ipv6/syncookies.c          | 12 +++++++++---
 net/ipv6/udp.c                 | 31 +++++++++++++++++++++++++++----
 net/rds/connection.c           | 12 +++++++++---
 19 files changed, 255 insertions(+), 132 deletions(-)

Greetings,

  Hannes
