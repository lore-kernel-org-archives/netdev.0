From: James Morris <jmorris@namei.org>
Subject: [PATCHSET 0/7] SECMARK 2.0
Date: Thu, 18 May 2006 05:20:53 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0605180458130.569@d.namei>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Patrick McHardy <kaber@trash.net>,
	Stephen Smalley <sds@tycho.nsa.gov>, netdev@vger.kernel.org,
	Karl MacMillan <kmacmillan@tresys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail8.sea5.speakeasy.net ([69.17.117.10]:34749 "EHLO
	mail8.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1751016AbWERJU5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 May 2006 05:20:57 -0400
To: "David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following patchset is an updated version of secmark, which I'd like to 
propose for inclusion in either Dave or Andrew's tree for subsequent merge 
into mainline during the 2.6.18 merge window.

Secmark implements a new scheme for adding security markings to packets 
via iptables, as well as changes to SELinux to use these markings for 
security policy enforcement.  The rationale for this scheme is explained 
and discussed in detail in the original threads: 
http://thread.gmane.org/gmane.linux.network/34927/ 
http://thread.gmane.org/gmane.linux.network/35244/

Since the last posting, I've fully separated the conntrack-related 
functionality of SECMARK into the CONNSECMARK target, following the 
original suggestion by Patrick McHardy.  This indeed keeps the code 
cleaner and only requires one extra rule per service.  I've also added a 
boot param for SELinux to control whether the new packet controls are used 
or not.

Examples of policy and rulesets, as well as a full archive of patches for 
iptables and SELinux userland, may be found at:
http://people.redhat.com/jmorris/selinux/secmark/

The code has been tested with various compilation options and in several 
scenarios, including with 'complicated' protocols such as FTP and also 
with the new generic conntrack code with IPv6 connection tracking.

I'm not sure if this would be better in Dave or Andrew's tree.  It touches 
a lot of the core networking, although not very heavily, and most of the 
Netfilter stuff is new targets.  There's already an SELinux patch in -mm 
which affects the SELinux components in this patchset (I rebased against 
current -mm because of this).

I'll send the Netfilter userland patches separately to the netfilter 
developers.

Cumulative diffstat:

 Documentation/kernel-parameters.txt          |    9 +
 include/linux/netfilter/xt_CONNSECMARK.h     |   13 +
 include/linux/netfilter/xt_SECMARK.h         |   26 ++
 include/linux/netfilter_ipv4/ip_conntrack.h  |    4 
 include/linux/selinux.h                      |   32 +++
 include/linux/skbuff.h                       |   22 ++
 include/net/netfilter/nf_conntrack.h         |    4 
 include/net/netfilter/nf_conntrack_compat.h  |   26 ++
 net/Kconfig                                  |    7 
 net/core/skbuff.c                            |    3 
 net/ipv4/ip_output.c                         |    1 
 net/ipv4/netfilter/Kconfig                   |   12 +
 net/ipv4/netfilter/ip_conntrack_core.c       |    3 
 net/ipv4/netfilter/ip_conntrack_standalone.c |    5 
 net/ipv4/netfilter/ipt_REJECT.c              |    1 
 net/ipv6/ip6_output.c                        |    1 
 net/netfilter/Kconfig                        |   32 +++
 net/netfilter/Makefile                       |    2 
 net/netfilter/nf_conntrack_core.c            |    3 
 net/netfilter/nf_conntrack_standalone.c      |    5 
 net/netfilter/xt_CONNSECMARK.c               |  155 +++++++++++++++++
 net/netfilter/xt_SECMARK.c                   |  156 +++++++++++++++++
 security/selinux/Kconfig                     |    2 
 security/selinux/exports.c                   |   22 ++
 security/selinux/hooks.c                     |  241 ++++++++++++++-------------
 security/selinux/include/av_perm_to_string.h |    3 
 security/selinux/include/av_permissions.h    |    3 
 security/selinux/include/class_to_string.h   |    1 
 security/selinux/include/flask.h             |    1 
 security/selinux/include/xfrm.h              |    2 
 security/selinux/selinuxfs.c                 |   59 ++++++
 security/selinux/xfrm.c                      |   12 -
 32 files changed, 747 insertions(+), 121 deletions(-)


-- 
James Morris
<jmorris@namei.org>
