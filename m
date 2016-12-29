From: Daniel Mack <daniel@zonque.org>
Subject: [PATCH v1 0/2] bpf: add longest prefix match map
Date: Thu, 29 Dec 2016 18:28:53 +0100
Message-ID: <20161229172855.14910-1-daniel@zonque.org>
Cc: dh.herrmann@gmail.com, daniel@iogearbox.net,
        netdev@vger.kernel.org, davem@davemloft.net,
        Daniel Mack <daniel@zonque.org>
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenfoo.org ([82.94.215.22]:45607 "EHLO mail.zonque.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753108AbcL2R3D (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 29 Dec 2016 12:29:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set adds a longest prefix match algorithm that can be used
to match IP addresses to a stored set of ranges. It is exposed as a
bpf map type.
   
Internally, data is stored in an unbalanced tree of nodes that has a
maximum height of n, where n is the prefixlen the trie was created
with.
 
Not that this has nothing to do with fib or fib6 and is in no way meant
to replace or share code with it. It's rather a much simpler
implementation that is specifically written with bpf maps in mind.
 
Patch 1/2 adds the implementation, and 2/2 an extensive test suite.
 
Feedback is much appreciated.
 
 
Thanks,
Daniel

Changelog:

rfc -> v1:
	* Add __rcu pointer annotations to make sparse happy
	* Fold _lpm_trie_find_target_node() into its only caller
	* Fix some minor documentation issues


Daniel Mack (1):
  bpf: add a longest prefix match trie map implementation

David Herrmann (1):
  bpf: Add tests for the lpm trie map

 include/uapi/linux/bpf.h                   |   7 +
 kernel/bpf/Makefile                        |   2 +-
 kernel/bpf/lpm_trie.c                      | 468 +++++++++++++++++++++++++++++
 tools/testing/selftests/bpf/.gitignore     |   1 +
 tools/testing/selftests/bpf/Makefile       |   4 +-
 tools/testing/selftests/bpf/test_lpm_map.c | 348 +++++++++++++++++++++
 6 files changed, 827 insertions(+), 3 deletions(-)
 create mode 100644 kernel/bpf/lpm_trie.c
 create mode 100644 tools/testing/selftests/bpf/test_lpm_map.c

-- 
2.9.3
