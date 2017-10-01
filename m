From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [BUG] bpf is broken in net-next
Date: Sun, 1 Oct 2017 14:02:30 -0700
Message-ID: <20171001140230.6a494b48@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:48849 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750993AbdJAVCi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 1 Oct 2017 17:02:38 -0400
Received: by mail-pg0-f50.google.com with SMTP id v78so260536pgb.5
        for <netdev@vger.kernel.org>; Sun, 01 Oct 2017 14:02:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Recent regression in net-next building bpf.c in samples/bpf now broken.

$ make samples/bpf/


  HOSTCC  samples/bpf/../../tools/lib/bpf/bpf.o
samples/bpf/../../tools/lib/bpf/bpf.c: In function =E2=80=98bpf_create_map_=
node=E2=80=99:
samples/bpf/../../tools/lib/bpf/bpf.c:76:13: error: =E2=80=98union bpf_attr=
=E2=80=99 has no member named =E2=80=98map_name=E2=80=99; did you mean =E2=
=80=98map_type=E2=80=99?
  memcpy(attr.map_name, name, min(name_len, BPF_OBJ_NAME_LEN - 1));
             ^
samples/bpf/../../tools/lib/bpf/bpf.c:76:44: error: =E2=80=98BPF_OBJ_NAME_L=
EN=E2=80=99 undeclared (first use in this function)
  memcpy(attr.map_name, name, min(name_len, BPF_OBJ_NAME_LEN - 1));
                                            ^
samples/bpf/../../tools/lib/bpf/bpf.c:49:27: note: in definition of macro =
=E2=80=98min=E2=80=99
 #define min(x, y) ((x) < (y) ? (x) : (y))
                           ^
samples/bpf/../../tools/lib/bpf/bpf.c:76:44: note: each undeclared identifi=
er is reported only once for each function it appears in
  memcpy(attr.map_name, name, min(name_len, BPF_OBJ_NAME_LEN - 1));
                                            ^
samples/bpf/../../tools/lib/bpf/bpf.c:49:27: note: in definition of macro =
=E2=80=98min=E2=80=99
 #define min(x, y) ((x) < (y) ? (x) : (y))
                           ^
samples/bpf/../../tools/lib/bpf/bpf.c: In function =E2=80=98bpf_create_map_=
in_map_node=E2=80=99:
samples/bpf/../../tools/lib/bpf/bpf.c:116:13: error: =E2=80=98union bpf_att=
r=E2=80=99 has no member named =E2=80=98map_name=E2=80=99; did you mean =E2=
=80=98map_type=E2=80=99?
  memcpy(attr.map_name, name, min(name_len, BPF_OBJ_NAME_LEN - 1));
             ^
samples/bpf/../../tools/lib/bpf/bpf.c:116:44: error: =E2=80=98BPF_OBJ_NAME_=
LEN=E2=80=99 undeclared (first use in this function)
  memcpy(attr.map_name, name, min(name_len, BPF_OBJ_NAME_LEN - 1));
                                            ^
samples/bpf/../../tools/lib/bpf/bpf.c:49:27: note: in definition of macro =
=E2=80=98min=E2=80=99
 #define min(x, y) ((x) < (y) ? (x) : (y))
                           ^
samples/bpf/../../tools/lib/bpf/bpf.c: In function =E2=80=98bpf_load_progra=
m_name=E2=80=99:
samples/bpf/../../tools/lib/bpf/bpf.c:154:13: error: =E2=80=98union bpf_att=
r=E2=80=99 has no member named =E2=80=98prog_name=E2=80=99; did you mean =
=E2=80=98prog_type=E2=80=99?
  memcpy(attr.prog_name, name, min(name_len, BPF_OBJ_NAME_LEN - 1));
             ^
samples/bpf/../../tools/lib/bpf/bpf.c:154:45: error: =E2=80=98BPF_OBJ_NAME_=
LEN=E2=80=99 undeclared (first use in this function)
  memcpy(attr.prog_name, name, min(name_len, BPF_OBJ_NAME_LEN - 1));
                                             ^
samples/bpf/../../tools/lib/bpf/bpf.c:49:27: note: in definition of macro =
=E2=80=98min=E2=80=99
 #define min(x, y) ((x) < (y) ? (x) : (y))
                           ^
scripts/Makefile.host:118: recipe for target 'samples/bpf/../../tools/lib/b=
pf/bpf.o' failed
