From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net] net: nsid cannot be allocated for a dead netns
Date: Wed, 16 Nov 2016 09:42:42 +0100
Message-ID: <dacfdac1-409b-3cef-f0fc-1516c06d8a02@6wind.com>
References: <CANaxB-yaizaZbUi-OaJLzy+k2fNOkTCb8L8uwBCw4L5axOCzdg@mail.gmail.com>
 <1479285671-1298-1-git-send-email-nicolas.dichtel@6wind.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        xiyou.wangcong@gmail.com
To: avagin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:38323 "EHLO
        mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751335AbcKPImq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 03:42:46 -0500
Received: by mail-wm0-f41.google.com with SMTP id f82so57002914wmf.1
        for <netdev@vger.kernel.org>; Wed, 16 Nov 2016 00:42:45 -0800 (PST)
In-Reply-To: <1479285671-1298-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 16/11/2016 à 09:41, Nicolas Dichtel a écrit :
> Andrei reports the following kmemleak error:
> unreferenced object 0xffff91badb543950 (size 2096):
>   comm "kworker/u4:0", pid 6, jiffies 4295152553 (age 28.418s)
>   hex dump (first 32 bytes):
>     00 00 00 00 00 00 00 00 00 cb 5f df ba 91 ff ff  .........._.....
>     00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
>   backtrace:
>     [<ffffffffb1865bea>] kmemleak_alloc+0x4a/0xa0
>     [<ffffffffb1243b38>] kmem_cache_alloc+0x128/0x280
>     [<ffffffffb142f5ab>] idr_layer_alloc+0x2b/0x90
>     [<ffffffffb142f9cd>] idr_get_empty_slot+0x34d/0x370
>     [<ffffffffb142fa4e>] idr_alloc+0x5e/0x110
>     [<ffffffffb170ac3d>] __peernet2id_alloc+0x6d/0x90
>     [<ffffffffb170bda5>] peernet2id_alloc+0x55/0xb0
>     [<ffffffffb1731216>] rtnl_fill_ifinfo+0xaa6/0x10a0
>     [<ffffffffb1733073>] rtmsg_ifinfo_build_skb+0x73/0xd0
>     [<ffffffffb17125d5>] rollback_registered_many+0x295/0x390
>     [<ffffffffb1712765>] unregister_netdevice_many+0x25/0x80
>     [<ffffffffb17138a5>] default_device_exit_batch+0x145/0x170
>     [<ffffffffb170ae52>] ops_exit_list.isra.4+0x52/0x60
>     [<ffffffffb170c17f>] cleanup_net+0x1bf/0x2a0
>     [<ffffffffb10b616f>] process_one_work+0x1ff/0x660
>     [<ffffffffb10b661e>] worker_thread+0x4e/0x480
> 
> There is no reason to try to allocate an nsid for a netns which is dying.
> 
> Reported-by: Andrei Vagin <avagin@gmail.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
'Fixes' tag is missing :/

Fixes: 0c7aecd4bde4 ("netns: add rtnl cmd to add and get peer netns ids")
