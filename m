From: Craig Gallek <kraigatgoog@gmail.com>
Subject: [PATCH net-next v2 0/2] libbpf: support more map options
Date: Mon,  2 Oct 2017 12:41:27 -0400
Message-ID: <20171002164129.47986-1-kraigatgoog@gmail.com>
Cc: Chonggang Li <chonggangli@google.com>, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f182.google.com ([209.85.216.182]:52103 "EHLO
        mail-qt0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751061AbdJBQlb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2017 12:41:31 -0400
Received: by mail-qt0-f182.google.com with SMTP id q4so8015919qtq.8
        for <netdev@vger.kernel.org>; Mon, 02 Oct 2017 09:41:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Craig Gallek <kraig@google.com>

The functional change to this series is the ability to use flags when
creating maps from object files loaded by libbpf.  In order to do this,
the first patch updates the library to handle map definitions that
differ in size from libbpf's struct bpf_map_def.

For object files with a larger map definition, libbpf will continue to load
if the unknown fields are all zero, otherwise the map is rejected.  If the
map definition in the object file is smaller than expected, libbpf will use
zero as a default value in the missing fields.

Craig Gallek (2):
  libbpf: parse maps sections of varying size
  libbpf: use map_flags when creating maps

 tools/lib/bpf/libbpf.c | 56 ++++++++++++++++++++++++++++++++++++++++++--------
 tools/lib/bpf/libbpf.h |  1 +
 2 files changed, 48 insertions(+), 9 deletions(-)

-- 
2.14.2.822.g60be5d43e6-goog
