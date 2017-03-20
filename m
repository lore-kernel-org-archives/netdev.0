From: Chenbo Feng <chenbofeng.kernel@gmail.com>
Subject: [PATCH net-next v4 0/3] net: core: Two Helper function about socket information
Date: Sun, 19 Mar 2017 17:08:41 -0700
Message-ID: <1489968524-2495-1-git-send-email-chenbofeng.kernel@gmail.com>
Cc: Lorenzo Colitti <lorenzo@google.com>,
        Willem de Bruijn <willemb@google.com>,
        Chenbo Feng <chenbofeng.kernel@gmail.com>
To: netdev@vger.kernel.org, Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:32934 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752017AbdCTAJn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 19 Mar 2017 20:09:43 -0400
Received: by mail-pf0-f193.google.com with SMTP id p189so9325304pfp.0
        for <netdev@vger.kernel.org>; Sun, 19 Mar 2017 17:08:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce two eBpf helper function to get the socket cookie and
socket uid for each packet. The helper function is useful when
the *sk field inside sk_buff is not empty. These helper functions
can be used on socket and uid based traffic monitoring programs.

Change since V3:
* Fixed some typos and incorrect comments in sample program
* replaced raw insns with BPF_STX_XADD and add it to libbpf.h
* Use a temp dir as mount point instead and added a check for
  the user input string.
* Make the get uid helper function returns the user namespace uid
  instead of kuid.
* Return a overflowuid instead of 0 when no uid information is found.

Change since V2:
* Add a sample program to demostrate the usage of the helper function.
* Moved the helper function proto invoking place.
* Add function header into tools/include
* Apply sk_to_full_sk() before getting uid.

Change since V1:
* Removed the unnecessary declarations and export command
* resolved conflict with master branch.
* Examine if the socket is a full socket before getting the uid.

Chenbo Feng (3):
  Add a helper function to get socket cookie in eBPF
  Add a eBPF helper function to retrieve socket uid
  A Sample of using socket cookie and uid for traffic monitoring

 include/linux/sock_diag.h                    |   1 +
 include/uapi/linux/bpf.h                     |  16 +-
 net/core/filter.c                            |  42 +++++
 net/core/sock_diag.c                         |   2 +-
 samples/bpf/cookie_uid_helper_example.c      | 229 +++++++++++++++++++++++++++
 samples/bpf/libbpf.h                         |  10 ++
 samples/bpf/run_cookie_uid_helper_example.sh |  14 ++
 tools/include/uapi/linux/bpf.h               |   4 +-
 8 files changed, 315 insertions(+), 3 deletions(-)
 create mode 100644 samples/bpf/cookie_uid_helper_example.c
 create mode 100755 samples/bpf/run_cookie_uid_helper_example.sh

-- 
2.7.4
