From: Chenbo Feng <chenbofeng.kernel@gmail.com>
Subject: [PATCH net-next v3 0/3] net: core: Two Helper function about socket information
Date: Wed, 22 Feb 2017 20:44:50 -0800
Message-ID: <1487825093-5221-1-git-send-email-chenbofeng.kernel@gmail.com>
Cc: Chenbo Feng <fengc@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:32850 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751049AbdBWEpd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2017 23:45:33 -0500
Received: by mail-pg0-f45.google.com with SMTP id z128so10267077pgb.0
        for <netdev@vger.kernel.org>; Wed, 22 Feb 2017 20:45:07 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chenbo Feng <fengc@google.com>

Introduce two eBpf helper function to get the socket cookie and
socket uid for each packet. The helper function is useful when
the *sk field inside sk_buff is not empty. These helper functions
can be used on socket and uid based traffic monitoring programs.

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
 net/core/filter.c                            |  36 +++++
 net/core/sock_diag.c                         |   2 +-
 samples/bpf/cookie_uid_helper_example.c      | 225 +++++++++++++++++++++++++++
 samples/bpf/run_cookie_uid_helper_example.sh |  14 ++
 tools/include/uapi/linux/bpf.h               |   4 +-
 7 files changed, 295 insertions(+), 3 deletions(-)
 create mode 100644 samples/bpf/cookie_uid_helper_example.c
 create mode 100755 samples/bpf/run_cookie_uid_helper_example.sh

-- 
2.7.4
