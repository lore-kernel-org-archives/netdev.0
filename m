From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH 0/9] The rest of the FIB patches (add key_vector to
 fib_table)
Date: Thu, 05 Mar 2015 14:50:28 -0800
Message-ID: <20150305224208.1642.34205.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51790 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752869AbbCEWua (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Mar 2015 17:50:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series is the rest of what I had planned for this kernel
release.  It adds a structure called key_vector which is embedded within
every tnode, leaf, and the trie root itself.  By doing this we can navigate
from any point within the trie to any other point fairly quickly and
avoiding NULL pointer checks in the case of a backtrace.  As a result we
can pipeline things a bit further since we don't have to worry about
dereferencing NULL in a backtrace.  This can amount to significant savings
on a long backtrace.

If needed these patches can be deferred/rebased depending on the needs of
the switchdev FIB offload work.

---

Alexander Duyck (9):
      fib_trie: Return pointer to tnode pointer in resize/inflate/halve
      fib_trie: Rename tnode to key_vector
      fib_trie: replace tnode_get_child functions with get_child macros
      fib_trie: Rename tnode_child_length to child_length
      fib_trie: Add tnode struct as a container for fields not needed in key_vector
      fib_trie: Move rcu from key_vector to tnode, add accessors.
      fib_trie: Pull empty_children and full_children into tnode
      fib_trie: Move parent from key_vector to tnode
      fib_trie: Add key vector to root, return parent key_vector in resize


 net/ipv4/fib_trie.c |  747 ++++++++++++++++++++++++++-------------------------
 1 file changed, 374 insertions(+), 373 deletions(-)

--
