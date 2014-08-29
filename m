From: Christophe Gouault <christophe.gouault@6wind.com>
Subject: Re: [PATCH net-next] xfrm: remove useless hash_resize_mutex locks
Date: Fri, 29 Aug 2014 09:42:10 +0200
Message-ID: <CADdy8HrQZQH0stZ2P_kEbw6KmnAGLr9WgQVWHEgeUByJ6znHrQ@mail.gmail.com>
References: <1409132986-12224-1-git-send-email-ying.xue@windriver.com>
	<20140829061150.GE6390@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ying Xue <ying.xue@windriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:49767 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752662AbaH2HmL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Aug 2014 03:42:11 -0400
Received: by mail-ig0-f178.google.com with SMTP id hn18so2201769igb.17
        for <netdev@vger.kernel.org>; Fri, 29 Aug 2014 00:42:10 -0700 (PDT)
In-Reply-To: <20140829061150.GE6390@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-08-29 8:11 GMT+02:00 Steffen Klassert <steffen.klassert@secunet.com>:
> Ccing Christophe Gouault as he currently reworks the policy
> hashing.

Thanks.

> One of Christophes patches will use this mutex in a worker of
> another work queue, so this mutex is really needed if I apply
> his patchset. See http://patchwork.ozlabs.org/patch/383486/

Yes right, the mutex is actually needed after this patch.

> I tend to apply Christophes patchset after some further testing,
> so we can't remove this mutex now.

>>  /* Generate new index... KAME seems to generate them ordered by cost
>> diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
>> index 0ab5413..de971b6 100644
>> --- a/net/xfrm/xfrm_state.c
>> +++ b/net/xfrm/xfrm_state.c
>> @@ -97,8 +97,6 @@ static unsigned long xfrm_hash_new_size(unsigned int state_hmask)
>>       return ((state_hmask + 1) << 1) * sizeof(struct hlist_head);
>>  }
>>
>> -static DEFINE_MUTEX(hash_resize_mutex);
>> -
>
> This one is still redundant, so we can remove it if there
> are no plans to do something similar to the xfrm_state
> hashing soon. Christophe?

I have no plans to work on the xfrm_state hashing soon. I think this
mutex can be removed.

Best Regards,
Christophe
