From: Joe Stringer <joe@ovn.org>
Subject: [PATCH net-next 0/3] tools lib bpf: Synchronize implementations
Date: Mon, 31 Oct 2016 11:39:14 -0700
Message-ID: <20161031183917.9938-1-joe@ovn.org>
Cc: wangnan0@huawei.com, ast@fb.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from slow1-d.mail.gandi.net ([217.70.178.86]:57064 "EHLO
        slow1-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755223AbcJaSq4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 14:46:56 -0400
Received: from relay2-d.mail.gandi.net (relay2-d.mail.gandi.net [217.70.183.194])
        by slow1-d.mail.gandi.net (Postfix) with ESMTP id 73B6547B282
        for <netdev@vger.kernel.org>; Mon, 31 Oct 2016 19:39:36 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update tools/lib/bpf to provide more functionality and improve interoperation
with other tools that generate and use eBPF code.

The kernel uapi headers are a bit newer than the version in the tools/
directory; synchronize those.

samples/bpf/libbpf* has a bit more functionality than tools/lib/bpf, so extend
tools/lib/bpf/bpf* with these functions to bring them into parity.

tools/lib/bpf cannot read ELFs that tc can read, and vice versa. Update the
map definition to be the same as in tc so the ELFs may be interchangeable
(at least for now; I don't have a long-term plan in mind to ensure this always
works).

Joe Stringer (3):
  tools lib bpf: Sync {tools,}/include/uapi/linux/bpf.h
  tools lib bpf: Sync with samples/bpf/libbpf
  tools lib bpf: Sync bpf_map_def with tc

 tools/include/uapi/linux/bpf.h |  51 ++++++++++
 tools/lib/bpf/bpf.c            | 139 ++++++++++++++++++++++-----
 tools/lib/bpf/bpf.h            | 208 +++++++++++++++++++++++++++++++++++++++--
 tools/lib/bpf/libbpf.c         |   3 +-
 tools/lib/bpf/libbpf.h         |  11 ++-
 5 files changed, 375 insertions(+), 37 deletions(-)

-- 
2.9.3
