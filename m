From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net] net: sched: don't use GFP_KERNEL under spin lock
Date: Tue, 5 Sep 2017 14:52:21 +0200
Message-ID: <20170905125221.GA7936@nanopsycho>
References: <20170905105442.30972-1-jakub.kicinski@netronome.com>
 <20170905115948.2fd38785@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:34381 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751002AbdIEMwZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 5 Sep 2017 08:52:25 -0400
Received: by mail-wr0-f194.google.com with SMTP id n33so1453690wrn.1
        for <netdev@vger.kernel.org>; Tue, 05 Sep 2017 05:52:24 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170905115948.2fd38785@cakuba.netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Sep 05, 2017 at 12:59:48PM CEST, kubakici@wp.pl wrote:
>Jiri, FWIW I also just noticed these, but they seem related to the
>earlier TC chain work?

What do you do to trigger this?

>
>unreferenced object 0xffff8807466f70c8 (size 64):
>  comm "tc", pid 1812, jiffies 4294932641 (age 1537.192s)
>  hex dump (first 32 bytes):
>    00 00 00 00 00 00 00 00 a0 83 e1 31 07 88 ff ff  ...........1....
>    d8 70 6f 46 07 88 ff ff d8 70 6f 46 07 88 ff ff  .poF.....poF....
>  backtrace:
>    [<ffffffffaa6b0118>] kmemleak_alloc+0x28/0x50
>    [<ffffffffa89a89b6>] kmem_cache_alloc_trace+0x1e6/0x550
>    [<ffffffffaa102827>] tcf_chain_create+0x97/0x460
>    [<ffffffffaa102f67>] tcf_block_get+0x127/0x230
>    [<ffffffffc03e8546>] ingress_init+0x76/0x110 [sch_ingress]
>    [<ffffffffaa0fbb1c>] qdisc_create+0x2ec/0x1100
>    [<ffffffffaa0fce1a>] tc_modify_qdisc+0x4ea/0x1ae0
>    [<ffffffffaa0355dc>] rtnetlink_rcv_msg+0xa3c/0x1400
>    [<ffffffffaa12e3cb>] netlink_rcv_skb+0x22b/0x4e0
>    [<ffffffffaa024b55>] rtnetlink_rcv+0x15/0x20
>    [<ffffffffaa12bddd>] netlink_unicast+0x47d/0x710
>    [<ffffffffaa12caef>] netlink_sendmsg+0xa7f/0x1140
>    [<ffffffffa9f15c52>] sock_sendmsg+0xe2/0x170
>    [<ffffffffa9f188bd>] ___sys_sendmsg+0x72d/0xcc0
>    [<ffffffffa9f1bfa2>] __sys_sendmsg+0xe2/0x260
>    [<ffffffffa9f1c132>] SyS_sendmsg+0x12/0x20
>unreferenced object 0xffff88074db6c008 (size 64):
>  comm "tc", pid 2097, jiffies 4294953636 (age 1453.212s)
>  hex dump (first 32 bytes):
>    00 00 00 00 00 00 00 00 60 a6 d1 31 07 88 ff ff  ........`..1....
>    18 c0 b6 4d 07 88 ff ff 18 c0 b6 4d 07 88 ff ff  ...M.......M....
>  backtrace:
>    [<ffffffffaa6b0118>] kmemleak_alloc+0x28/0x50
>    [<ffffffffa89a89b6>] kmem_cache_alloc_trace+0x1e6/0x550
>    [<ffffffffaa102827>] tcf_chain_create+0x97/0x460
>    [<ffffffffaa102f67>] tcf_block_get+0x127/0x230
>    [<ffffffffc03e8546>] ingress_init+0x76/0x110 [sch_ingress]
>    [<ffffffffaa0fbb1c>] qdisc_create+0x2ec/0x1100
>    [<ffffffffaa0fce1a>] tc_modify_qdisc+0x4ea/0x1ae0
>    [<ffffffffaa0355dc>] rtnetlink_rcv_msg+0xa3c/0x1400
>    [<ffffffffaa12e3cb>] netlink_rcv_skb+0x22b/0x4e0
>    [<ffffffffaa024b55>] rtnetlink_rcv+0x15/0x20
>    [<ffffffffaa12bddd>] netlink_unicast+0x47d/0x710
>    [<ffffffffaa12caef>] netlink_sendmsg+0xa7f/0x1140
>    [<ffffffffa9f15c52>] sock_sendmsg+0xe2/0x170
>    [<ffffffffa9f188bd>] ___sys_sendmsg+0x72d/0xcc0
>    [<ffffffffa9f1bfa2>] __sys_sendmsg+0xe2/0x260
>    [<ffffffffa9f1c132>] SyS_sendmsg+0x12/0x20
>unreferenced object 0xffff880749f82a48 (size 64):
>  comm "tc", pid 2381, jiffies 4294972986 (age 1375.812s)
>  hex dump (first 32 bytes):
>    00 00 00 00 00 00 00 00 c0 b7 31 31 07 88 ff ff  ..........11....
>    58 2a f8 49 07 88 ff ff 58 2a f8 49 07 88 ff ff  X*.I....X*.I....
>  backtrace:
>    [<ffffffffaa6b0118>] kmemleak_alloc+0x28/0x50
>    [<ffffffffa89a89b6>] kmem_cache_alloc_trace+0x1e6/0x550
>    [<ffffffffaa102827>] tcf_chain_create+0x97/0x460
>    [<ffffffffaa102f67>] tcf_block_get+0x127/0x230
>    [<ffffffffc03e8546>] ingress_init+0x76/0x110 [sch_ingress]
>    [<ffffffffaa0fbb1c>] qdisc_create+0x2ec/0x1100
>    [<ffffffffaa0fce1a>] tc_modify_qdisc+0x4ea/0x1ae0
>    [<ffffffffaa0355dc>] rtnetlink_rcv_msg+0xa3c/0x1400
>    [<ffffffffaa12e3cb>] netlink_rcv_skb+0x22b/0x4e0
>    [<ffffffffaa024b55>] rtnetlink_rcv+0x15/0x20
>    [<ffffffffaa12bddd>] netlink_unicast+0x47d/0x710
>    [<ffffffffaa12caef>] netlink_sendmsg+0xa7f/0x1140
>    [<ffffffffa9f15c52>] sock_sendmsg+0xe2/0x170
>    [<ffffffffa9f188bd>] ___sys_sendmsg+0x72d/0xcc0
>    [<ffffffffa9f1bfa2>] __sys_sendmsg+0xe2/0x260
>    [<ffffffffa9f1c132>] SyS_sendmsg+0x12/0x20
>unreferenced object 0xffff8803fd855a08 (size 64):
>  comm "tc", pid 2663, jiffies 4294992152 (age 1299.328s)
>  hex dump (first 32 bytes):
>    00 00 00 00 00 00 00 00 20 49 80 31 07 88 ff ff  ........ I.1....
>    18 5a 85 fd 03 88 ff ff 18 5a 85 fd 03 88 ff ff  .Z.......Z......
>  backtrace:
>    [<ffffffffaa6b0118>] kmemleak_alloc+0x28/0x50
>    [<ffffffffa89a89b6>] kmem_cache_alloc_trace+0x1e6/0x550
>    [<ffffffffaa102827>] tcf_chain_create+0x97/0x460
>    [<ffffffffaa102f67>] tcf_block_get+0x127/0x230
>    [<ffffffffc03e8546>] ingress_init+0x76/0x110 [sch_ingress]
>    [<ffffffffaa0fbb1c>] qdisc_create+0x2ec/0x1100
>    [<ffffffffaa0fce1a>] tc_modify_qdisc+0x4ea/0x1ae0
>    [<ffffffffaa0355dc>] rtnetlink_rcv_msg+0xa3c/0x1400
>    [<ffffffffaa12e3cb>] netlink_rcv_skb+0x22b/0x4e0
>    [<ffffffffaa024b55>] rtnetlink_rcv+0x15/0x20
>    [<ffffffffaa12bddd>] netlink_unicast+0x47d/0x710
>    [<ffffffffaa12caef>] netlink_sendmsg+0xa7f/0x1140
>    [<ffffffffa9f15c52>] sock_sendmsg+0xe2/0x170
>    [<ffffffffa9f188bd>] ___sys_sendmsg+0x72d/0xcc0
>    [<ffffffffa9f1bfa2>] __sys_sendmsg+0xe2/0x260
>    [<ffffffffa9f1c132>] SyS_sendmsg+0x12/0x20
>unreferenced object 0xffff88071b096f28 (size 64):
>  comm "tc", pid 2943, jiffies 4295013397 (age 1214.352s)
>  hex dump (first 32 bytes):
>    00 00 00 00 00 00 00 00 c0 37 e7 30 07 88 ff ff  .........7.0....
>    38 6f 09 1b 07 88 ff ff 38 6f 09 1b 07 88 ff ff  8o......8o......
>  backtrace:
>    [<ffffffffaa6b0118>] kmemleak_alloc+0x28/0x50
>    [<ffffffffa89a89b6>] kmem_cache_alloc_trace+0x1e6/0x550
>    [<ffffffffaa102827>] tcf_chain_create+0x97/0x460
>    [<ffffffffaa102f67>] tcf_block_get+0x127/0x230
>    [<ffffffffc03e8546>] ingress_init+0x76/0x110 [sch_ingress]
>    [<ffffffffaa0fbb1c>] qdisc_create+0x2ec/0x1100
>    [<ffffffffaa0fce1a>] tc_modify_qdisc+0x4ea/0x1ae0
>    [<ffffffffaa0355dc>] rtnetlink_rcv_msg+0xa3c/0x1400
>    [<ffffffffaa12e3cb>] netlink_rcv_skb+0x22b/0x4e0
>    [<ffffffffaa024b55>] rtnetlink_rcv+0x15/0x20
>    [<ffffffffaa12bddd>] netlink_unicast+0x47d/0x710
>    [<ffffffffaa12caef>] netlink_sendmsg+0xa7f/0x1140
>    [<ffffffffa9f15c52>] sock_sendmsg+0xe2/0x170
>    [<ffffffffa9f188bd>] ___sys_sendmsg+0x72d/0xcc0
>    [<ffffffffa9f1bfa2>] __sys_sendmsg+0xe2/0x260
>    [<ffffffffa9f1c132>] SyS_sendmsg+0x12/0x20
>unreferenced object 0xffff880731f66568 (size 64):
>  comm "tc", pid 3263, jiffies 4295033366 (age 1134.480s)
>  hex dump (first 32 bytes):
>    00 00 00 00 00 00 00 00 00 95 64 65 07 88 ff ff  ..........de....
>    78 65 f6 31 07 88 ff ff 78 65 f6 31 07 88 ff ff  xe.1....xe.1....
>  backtrace:
>    [<ffffffffaa6b0118>] kmemleak_alloc+0x28/0x50
>    [<ffffffffa89a89b6>] kmem_cache_alloc_trace+0x1e6/0x550
>    [<ffffffffaa102827>] tcf_chain_create+0x97/0x460
>    [<ffffffffaa102f67>] tcf_block_get+0x127/0x230
>    [<ffffffffc03e8546>] ingress_init+0x76/0x110 [sch_ingress]
>    [<ffffffffaa0fbb1c>] qdisc_create+0x2ec/0x1100
>    [<ffffffffaa0fce1a>] tc_modify_qdisc+0x4ea/0x1ae0
>    [<ffffffffaa0355dc>] rtnetlink_rcv_msg+0xa3c/0x1400
>    [<ffffffffaa12e3cb>] netlink_rcv_skb+0x22b/0x4e0
>    [<ffffffffaa024b55>] rtnetlink_rcv+0x15/0x20
>    [<ffffffffaa12bddd>] netlink_unicast+0x47d/0x710
>    [<ffffffffaa12caef>] netlink_sendmsg+0xa7f/0x1140
>    [<ffffffffa9f15c52>] sock_sendmsg+0xe2/0x170
>    [<ffffffffa9f188bd>] ___sys_sendmsg+0x72d/0xcc0
>    [<ffffffffa9f1bfa2>] __sys_sendmsg+0xe2/0x260
>    [<ffffffffa9f1c132>] SyS_sendmsg+0x12/0x20
