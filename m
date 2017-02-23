From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/8] Netfilter fixes for net
Date: Thu, 23 Feb 2017 12:14:01 +0100
Message-ID: <1487848449-2731-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

The following patchset contains Netfilter fixes for your net tree,
they are:

1) Revisit warning logic when not applying default helper assignment.
   Jiri Kosina considers we are breaking existing setups and not warning
   our users accordinly now that automatic helper assignment has been
   turned off by default. So let's make him happy by spotting the warning
   by when we find a helper but we cannot attach, instead of warning on the
   former deprecated behaviour. Patch from Jiri Kosina.

2) Two patches to fix regression in ctnetlink interfaces with
   nfnetlink_queue. Specifically, perform more relaxed in CTA_STATUS
   and do not bail out if CTA_HELP indicates the same helper that we
   already have. Patches from Kevin Cernekee.

3) A couple of bugfixes for ipset via Jozsef Kadlecsik. Due to wrong
   index logic in hash set types and null pointer exception in the
   list:set type.

4) hashlimit bails out with correct userspace parameters due to wrong
   arithmetics in the code that avoids "divide by zero" when
   transforming the userspace timing in milliseconds to token credits.
   Patch from Alban Browaeys.

5) Fix incorrect NFQA_VLAN_MAX definition, patch from
   Ken-ichirou MATSUZAWA.

6) Don't not declare nfnetlink batch error list as static, since this
   may be used by several subsystems at the same time. Patch from
   Liping Zhang.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Thanks!

----------------------------------------------------------------

The following changes since commit cafe8df8b9bc9aa3dffa827c1a6757c6cd36f657:

  net: phy: Fix lack of reference count on PHY driver (2017-02-02 22:59:43 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git HEAD

for you to fetch changes up to 3ef767e5cbd405abfd01339c7e5daaf98e037be2:

  Merge branch 'master' of git://blackhole.kfki.hu/nf (2017-02-21 14:01:05 +0100)

----------------------------------------------------------------
Alban Browaeys (1):
      netfilter: xt_hashlimit: Fix integer divide round to zero.

Jiri Kosina (1):
      netfilter: nf_ct_helper: warn when not applying default helper assignment

Jozsef Kadlecsik (1):
      Fix bug: sometimes valid entries in hash:* types of sets were evicted

Ken-ichirou MATSUZAWA (1):
      netfilter: nfnetlink_queue: fix NFQA_VLAN_MAX definition

Kevin Cernekee (2):
      netfilter: ctnetlink: Fix regression in CTA_STATUS processing
      netfilter: ctnetlink: Fix regression in CTA_HELP processing

Liping Zhang (1):
      netfilter: nfnetlink: remove static declaration from err_list

Pablo Neira Ayuso (1):
      Merge branch 'master' of git://blackhole.kfki.hu/nf

Vishwanath Pai (1):
      netfilter: ipset: Null pointer exception in ipset list:set

 include/uapi/linux/netfilter/nf_conntrack_common.h |  4 ++
 include/uapi/linux/netfilter/nfnetlink_queue.h     |  2 +-
 net/netfilter/ipset/ip_set_hash_gen.h              |  2 +-
 net/netfilter/ipset/ip_set_list_set.c              |  9 +++--
 net/netfilter/nf_conntrack_helper.c                | 39 +++++++++++++-------
 net/netfilter/nf_conntrack_netlink.c               | 43 +++++++++++++++++++---
 net/netfilter/nfnetlink.c                          |  2 +-
 net/netfilter/xt_hashlimit.c                       | 25 +++++--------
 8 files changed, 86 insertions(+), 40 deletions(-)
