From: Louie Lu <louie.lu@hopebaytech.com>
Subject: Assertion faileda at samples/bpf/test_maps
Date: Sun, 2 Oct 2016 14:55:42 +0800
Message-ID: <CAEQ0BR4j65Upa_ZLo6yC1khOprvXx1_iVxCKuSxbn+Df1mo_OQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f173.google.com ([209.85.161.173]:33947 "EHLO
        mail-yw0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750864AbcJBGzo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 2 Oct 2016 02:55:44 -0400
Received: by mail-yw0-f173.google.com with SMTP id g192so91881822ywh.1
        for <netdev@vger.kernel.org>; Sat, 01 Oct 2016 23:55:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi everyone,

I'm now playing net-next samples/bpf things, and I found that
test_maps will give an assertion

```
test_maps: /home/grd/linux/net-next/samples/bpf/test_maps.c:146:
test_percpu_hashmap_sanity: Assertion `bpf_lookup_elem(map_fd, &key,
value) == -1 && errno == ENOENT' failed.
[1]    20706 abort (core dumped)  ./test_maps
```

I've done the check at [[iovisor-dev] Assertion fails at
samples/bpf/test_maps](http://lists.iovisor.org/pipermail/iovisor-dev/2016-June/000281.html)
which tells me to set ulimit to unlimited or patching by setrlimit().

The problem is bpf_lookup_elem return -1, and errno return 0.

I'm using Intel(R) Core(TM) i7-2640M and net-next commit:
803783849fed11, 4.8.0-rc7-ARCH-02283-g8037838.

And, a strange this is when I done this at QEMU, test_maps perform
will and pass the test.

Is that my hardware problem or something else?


Thanks.

Louie Lu.
