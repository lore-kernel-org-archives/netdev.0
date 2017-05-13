From: David Miller <davem@davemloft.net>
Subject: [PATCH 0/3] bpf: Track MAP pointer alignment
Date: Fri, 12 May 2017 22:28:40 -0400 (EDT)
Message-ID: <20170512.222840.1275746794429510985.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39604 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750782AbdEMC2o (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 12 May 2017 22:28:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch series updates the BPF verifier to properly track MAP
access alignment, just as we already do for packet pointers.

The two main elements of the implementation are putting the register
offset into a shared rather than reg type specific area of the
verifier register tracking strcutre, and also eliding packet pointer
specific checks when managing MAP pointer alignment.

More details of the implementation are in the commit message for patch
#2.

Patch #3 removes alignment restrictions from various test_verifier.c
tests which are no longer necessary with this MAP alignment
infrastructure in place.  Further improvements are possible, but
I didn't want to be overly ambitious here.

In the future we can add some MAP tests to test_align.c as well.

Signed-off-by: David S. Miller <davem@davemloft.net>
