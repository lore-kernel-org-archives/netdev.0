From: Chenbo Feng <chenbofeng.kernel@gmail.com>
Subject: [PATCH net-next v8 0/3] net: core: Two Helper function about socket information
Date: Wed, 22 Mar 2017 17:27:33 -0700
Message-ID: <1490228856-4546-1-git-send-email-chenbofeng.kernel@gmail.com>
Cc: Lorenzo Colitti <lorenzo@google.com>,
        Willem de Bruijn <willemb@google.com>,
        Chenbo Feng <fengc@google.com>
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
        Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36020 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753004AbdCWA1p (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 20:27:45 -0400
Received: by mail-pf0-f193.google.com with SMTP id r137so25305339pfr.3
        for <netdev@vger.kernel.org>; Wed, 22 Mar 2017 17:27:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chenbo Feng <fengc@google.com>

Introduce two eBpf helper function to get the socket cookie and
socket uid for each packet. The helper function is useful when
the *sk field inside sk_buff is not empty. These helper functions
can be used on socket and uid based traffic monitoring programs.

Change since V7:
* change the user namespace of uid helper function to sock_net(sk)->user_ns

Change since V6:
* change the user namespace of uid helper function back to init_user_ns
  since in some situation, for example, pinned bpf object, the current
  user namespace is not always applicable. 

Change since V5:
* Delete unnecessary blank lines in sample program.
* Refine the variable orders in get_uid helper function.

Change since V4:
* Using current user namespace to get uid instead of using init_ns.
* Add compiling setup of example program in to Makefile.
* Change the name style of the example program binaries.

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

Chenbo Feng (3):
  Add a helper function to get socket cookie in eBPF
  Add a eBPF helper function to retrieve socket uid
  A Sample of using socket cookie and uid for traffic monitoring

 include/linux/sock_diag.h                    |   1 +
 include/uapi/linux/bpf.h                     |  16 +-
 net/core/filter.c                            |  39 +++++
 net/core/sock_diag.c                         |   2 +-
 samples/bpf/Makefile                         |   3 +
 samples/bpf/cookie_uid_helper_example.c      | 217 +++++++++++++++++++++++++++
 samples/bpf/libbpf.h                         |  10 ++
 samples/bpf/run_cookie_uid_helper_example.sh |  14 ++
 tools/include/uapi/linux/bpf.h               |   4 +-
 9 files changed, 303 insertions(+), 3 deletions(-)
 create mode 100644 samples/bpf/cookie_uid_helper_example.c
 create mode 100755 samples/bpf/run_cookie_uid_helper_example.sh

-- 
2.7.4
