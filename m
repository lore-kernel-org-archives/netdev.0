From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/8] netfilter updates for net-next
Date: Wed, 14 Jan 2015 21:34:41 +0100
Message-ID: <1421267689-24894-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:49637 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751214AbbANUcA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jan 2015 15:32:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

The following patchset contains netfilter updates for net-next, just a
bunch of cleanups and small enhancement to selectively flush conntracks
in ctnetlink, more specifically the patches are:

1) Rise default number of buckets in conntrack from 16384 to 65536 in
   systems with >= 4GBytes, patch from Marcelo Leitner.

2) Small refactor to save one level on indentation in xt_osf, from
   Joe Perches.

3) Remove unnecessary sizeof(char) in nf_log, from Fabian Frederick.

4) Another small cleanup to remove redundant variable in nfnetlink,
   from Duan Jiong.

5) Fix compilation warning in nfnetlink_cthelper on parisc, from
   Chen Gang.

6) Fix wrong format in debugging for ctseqadj, from Gao feng.

7) Selective conntrack flushing through the mark for ctnetlink, patch
   from Kristian Evensen.

8) Remove nf_ct_conntrack_flush_report() exported symbol now that is
   not required anymore after the selective flushing patch, again from
   Kristian.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git

Thanks!

----------------------------------------------------------------

The following changes since commit f96fe225677b3efb74346ebd56fafe3997b02afa:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2014-12-12 16:11:12 -0800)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git master

for you to fetch changes up to ae406bd0572be97a46d72e8a5e97c33c3168388c:

  netfilter: conntrack: Remove nf_ct_conntrack_flush_report (2015-01-08 12:16:58 +0100)

----------------------------------------------------------------
Chen Gang (1):
      netfilter: nfnetlink_cthelper: Remove 'const' and '&' to avoid warnings

Duan Jiong (1):
      netfilter: nfnetlink: remove redundant variable nskb

Fabian Frederick (1):
      netfilter: log: remove unnecessary sizeof(char)

Gao feng (1):
      netfilter: nf_ct_seqadj: print ack seq in the right host byte order

Joe Perches (1):
      netfilter: xt_osf: Use continue to reduce indentation

Kristian Evensen (2):
      netfilter: conntrack: Flush connections with a given mark
      netfilter: conntrack: Remove nf_ct_conntrack_flush_report

Marcelo Leitner (1):
      netfilter: conntrack: adjust nf_conntrack_buckets default value

 Documentation/networking/nf_conntrack-sysctl.txt |    3 +-
 include/net/netfilter/nf_conntrack.h             |    2 -
 net/netfilter/nf_conntrack_core.c                |   17 +--
 net/netfilter/nf_conntrack_netlink.c             |   89 ++++++++----
 net/netfilter/nf_conntrack_seqadj.c              |    6 +-
 net/netfilter/nf_log.c                           |    3 +-
 net/netfilter/nfnetlink.c                        |   15 +-
 net/netfilter/nfnetlink_cthelper.c               |    4 +-
 net/netfilter/xt_osf.c                           |  169 +++++++++++-----------
 9 files changed, 172 insertions(+), 136 deletions(-)
