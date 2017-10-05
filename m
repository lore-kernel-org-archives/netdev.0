From: Craig Gallek <kraigatgoog@gmail.com>
Subject: [PATCH net-next v3 0/2] libbpf: support more map options
Date: Thu,  5 Oct 2017 10:41:56 -0400
Message-ID: <20171005144158.14860-1-kraigatgoog@gmail.com>
Cc: Chonggang Li <chonggangli@google.com>, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f171.google.com ([209.85.220.171]:51584 "EHLO
        mail-qk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750965AbdJEOmB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2017 10:42:01 -0400
Received: by mail-qk0-f171.google.com with SMTP id 17so14887460qkq.8
        for <netdev@vger.kernel.org>; Thu, 05 Oct 2017 07:42:01 -0700 (PDT)
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

 tools/lib/bpf/libbpf.c | 72 +++++++++++++++++++++++++++++---------------------
 tools/lib/bpf/libbpf.h |  1 +
 2 files changed, 43 insertions(+), 30 deletions(-)

-- 
v3:
  - explicit memcpy instead of struct assignment.
  - remove unnecessary bpf_object__validate_maps function

v2
  - determine bpf_map_def structure size dynamically from object file

2.14.2.920.gcf0c67979c-goog
