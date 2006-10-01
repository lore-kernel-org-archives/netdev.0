From: Venkat Yekkirala <vyekkirala@trustedcs.com>
Subject: [PATCH 0/9] secid reconciliation-v04: Repost patchset with updates
Date: Sun, 01 Oct 2006 16:26:03 -0500
Message-ID: <4520326B.4020008@trustedcs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: selinux@tycho.nsa.gov, jmorris@namei.org, sds@tycho.nsa.gov,
	paul.moore@hp.com, eparis@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:48974 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S932375AbWJAV0r
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Oct 2006 17:26:47 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset is relative to davem's net-2.6.git

The following are the changes included in this patchset since the previous post:

- Create IPSec SAs to be acquired with the creating sock's context as opposed
  to that of the matching SPD rule, resulting in a simpler SPD as well as policy.
- Set peer_sid on tcp sockets to the reconciled secmark so trusted applications
  can retrieve and service the data at the appropriate context. Also return secmark
  when security is queried for a UDP packet.
- Fix minor things from James Morris' review.

Paul, please spin a new patch to bring NetLabel into the reconciliation path
as well as to address any NetLabel changes needed in regard to the above.

Please consider for inclusion in 2.6.19.

 include/linux/security.h                     |   51 ++++-
 include/linux/skbuff.h                       |   49 +++++
 include/net/ip.h                             |   31 +++
 include/net/request_sock.h                   |   18 ++
 include/net/xfrm.h                           |   45 ++---
 net/dccp/ipv4.c                              |    5 
 net/ipv4/icmp.c                              |    4 
 net/ipv4/ip_output.c                         |    6 
 net/ipv4/tcp_ipv4.c                          |    1 
 net/ipv6/ip6_output.c                        |    5 
 net/ipv6/netfilter/ip6t_REJECT.c             |    2 
 net/netfilter/xt_CONNSECMARK.c               |   72 ++++++--
 net/netfilter/xt_SECMARK.c                   |   45 ++++-
 security/dummy.c                             |   13 +
 security/selinux/hooks.c                     |  148 +++++++++++++----
 security/selinux/include/av_perm_to_string.h |    2 
 security/selinux/include/av_permissions.h    |    2 
 security/selinux/include/xfrm.h              |   11 -
 security/selinux/xfrm.c                      |   66 +++----
 19 files changed, 450 insertions(+), 126 deletions(-)
