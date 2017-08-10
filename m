From: Tonghao Zhang <xiangxia.m.yue@gmail.com>
Subject: Re: [PATCH net-next] skbuff: Add BUG_ON in skb_init.
Date: Thu, 10 Aug 2017 14:10:12 +0800
Message-ID: <CAMDZJNVFP=1f1r4fQN=dnQ4Ve8+VzGfY7cHUe6Vv8tsECUmraw@mail.gmail.com>
References: <1502280278-9970-1-git-send-email-xiangxia.m.yue@gmail.com>
 <1502280278-9970-2-git-send-email-xiangxia.m.yue@gmail.com> <20170809.224939.550080421760909361.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:35913 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751332AbdHJGKO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2017 02:10:14 -0400
Received: by mail-oi0-f68.google.com with SMTP id b130so7720305oii.3
        for <netdev@vger.kernel.org>; Wed, 09 Aug 2017 23:10:13 -0700 (PDT)
In-Reply-To: <20170809.224939.550080421760909361.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks a lot. I found it when reviewing this codes. and BUG_ON is
added  in the init_inodecache(). We may remove it or not ?

diff --git a/net/socket.c b/net/socket.c
index b332d1e..ebee3ee 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -296,7 +296,6 @@ static void init_inodecache(void)
                                               SLAB_RECLAIM_ACCOUNT |
                                               SLAB_MEM_SPREAD | SLAB_ACCOUNT),
                                              init_once);
-       BUG_ON(sock_inode_cachep == NULL);
 }

 static const struct super_operations sockfs_ops = {

On Thu, Aug 10, 2017 at 1:49 PM, David Miller <davem@davemloft.net> wrote:
> From: Tonghao Zhang <xiangxia.m.yue@gmail.com>
> Date: Wed,  9 Aug 2017 05:04:38 -0700
>
>> When initializing the skbuff SLAB cache, we should make
>> sure it is successful. Adding BUG_ON to check it and
>> init_inodecache() is in the same case.
>>
>> Signed-off-by: Tonghao Zhang <xiangxia.m.yue@gmail.com>
>> ---
>>  net/core/skbuff.c | 2 ++
>>  1 file changed, 2 insertions(+)
>>
>> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
>> index 42b62c716a33..9513de519870 100644
>> --- a/net/core/skbuff.c
>> +++ b/net/core/skbuff.c
>> @@ -3904,6 +3904,8 @@ void __init skb_init(void)
>>                                               0,
>>                                               SLAB_HWCACHE_ALIGN|SLAB_PANIC,
>>                                               NULL);
>> +     BUG_ON(skbuff_head_cache == NULL);
>> +     BUG_ON(skbuff_fclone_cache == NULL);
>>  }
>
> I know you guys want every allocation to be explicitly checked so that
> everything is consistent for static code analysis checkers.
>
> But this is just wasted code.
>
> The first allocation will take a NULL dereference and the backtrace
> will make it completely clear which SLAB cache was NULL and couldn't
> be allocated.
>
> So there is no real value to adding these checks.
>
> So I'm not applying this, sorry.
>
> The same logic goes for your other patch of this nature.
>
