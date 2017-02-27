From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/6] Netfilter fixes for net
Date: Mon, 27 Feb 2017 12:35:36 +0100
Message-ID: <1488195342-2678-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:47852 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751909AbdB0Lgl (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 27 Feb 2017 06:36:41 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 76D47E620
        for <netdev@vger.kernel.org>; Mon, 27 Feb 2017 12:35:55 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 42287DA846
        for <netdev@vger.kernel.org>; Mon, 27 Feb 2017 12:35:55 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id B7191DA81C
        for <netdev@vger.kernel.org>; Mon, 27 Feb 2017 12:35:51 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

The following patchset contains netfilter fixes for you net tree,
they are:

1) Missing ct zone size in the nft_ct initialization path, patch
   from Florian Westphal.

2) Two patches for netfilter uapi headers, one to remove unnecessary
   sysctl.h inclusion and another to fix compilation of xt_hashlimit.h
   in userspace, from Dmitry V. Levin.

3) Patch to fix a sloppy change in nf_ct_expect that incorrectly
   simplified nf_ct_expect_related_report() in the previous nf-next
   batch. This also includes another patch for __nf_ct_expect_check()
   to report success by returning 0 to keep it consistent with other
   existing functions. From Jarno Rajahalme.

4) The ->walk() iterator of the new bitmap set type goes over the real
   bitmap size, this results in incorrect dumps when NFTA_SET_USERDATA
   is used.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Thanks!

----------------------------------------------------------------

The following changes since commit 9c4713701c01e4cef6e2315c2818abc919ffb0de:

  bpf: Fix bpf_xdp_event_output (2017-02-23 13:53:42 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git HEAD

for you to fetch changes up to 13aa5a8f498dacd5f1a8e35be72af47e630fb8c6:

  netfilter: nft_set_bitmap: incorrect bitmap size (2017-02-26 21:00:19 +0100)

----------------------------------------------------------------
Dmitry V. Levin (2):
      uapi: stop including linux/sysctl.h in uapi/linux/netfilter.h
      uapi: fix linux/netfilter/xt_hashlimit.h userspace compilation error

Florian Westphal (1):
      netfilter: nft_ct: fix random validation errors for zone set support

Jarno Rajahalme (2):
      netfilter: nf_ct_expect: nf_ct_expect_related_report(): Return zero on success.
      netfilter: nf_ct_expect: Change __nf_ct_expect_check() return value.

Pablo Neira Ayuso (1):
      netfilter: nft_set_bitmap: incorrect bitmap size

 include/uapi/linux/netfilter.h              | 1 -
 include/uapi/linux/netfilter/xt_hashlimit.h | 1 +
 net/netfilter/nf_conntrack_expect.c         | 6 +++---
 net/netfilter/nft_ct.c                      | 1 +
 net/netfilter/nft_set_bitmap.c              | 2 +-
 5 files changed, 6 insertions(+), 5 deletions(-)
