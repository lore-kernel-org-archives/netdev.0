From: Joe Stringer <joe@ovn.org>
Subject: [PATCHv2 perf/core 0/2] libbpf: Synchronize implementations
Date: Wed, 16 Nov 2016 09:43:22 -0800
Message-ID: <20161116174324.29675-1-joe@ovn.org>
Cc: netdev@vger.kernel.org, wangnan0@huawei.com, ast@fb.com,
        daniel@iogearbox.net, acme@kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay6-d.mail.gandi.net ([217.70.183.198]:56776 "EHLO
        relay6-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752210AbcKPRni (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 12:43:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update tools/lib/bpf to provide more functionality and improve interoperation
with other tools that generate and use eBPF code:
* The kernel uapi headers are a bit newer than the version in the tools/
  directory; synchronize those.
* samples/bpf/libbpf* has a bit more functionality than tools/lib/bpf, so
  extend tools/lib/bpf/bpf* with these functions to bring them into parity.

I've got a separate series to update samples/bpf/* to rely on these libraries,
but there's a conflict with davem's tree at the moment so I suppose that the
way forward is to get these patches through first, then take the samples
through net-next at a later time.

---
v2: Don't shift non-bpf code into libbpf.
    Drop the patch to synchronize ELF definitions with tc.
v1: https://www.mail-archive.com/netdev@vger.kernel.org/msg135088.html
    First post.

Joe Stringer (2):
  tools lib bpf: Sync {tools,}/include/uapi/linux/bpf.h
  tools lib bpf: Sync with samples/bpf/libbpf

 tools/include/uapi/linux/bpf.h |  51 +++++++++++
 tools/lib/bpf/bpf.c            | 107 +++++++++++++++++-----
 tools/lib/bpf/bpf.h            | 202 +++++++++++++++++++++++++++++++++++++++--
 tools/lib/bpf/libbpf.c         |   3 +-
 4 files changed, 330 insertions(+), 33 deletions(-)

-- 
2.9.3
