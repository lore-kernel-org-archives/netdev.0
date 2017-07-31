From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH 11/12] net: add notifier hooks for devmap bpf
 map
Date: Mon, 31 Jul 2017 07:47:43 -0700
Message-ID: <597F430F.3050000@gmail.com>
References: <20170717160759.24315.7464.stgit@john-Precision-Tower-5810> <20170717163002.24315.38734.stgit@john-Precision-Tower-5810> <20170730132931.gmzb6r4qaxxpsuir@sasha-lappy> <597EF067.1090605@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "ast@fb.com" <ast@fb.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "brouer@redhat.com" <brouer@redhat.com>,
        "andy@greyhouse.net" <andy@greyhouse.net>
To: Daniel Borkmann <daniel@iogearbox.net>,
        "Levin, Alexander (Sasha Levin)" <alexander.levin@verizon.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33243 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751951AbdGaOr6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 10:47:58 -0400
Received: by mail-pf0-f194.google.com with SMTP id k72so23084944pfj.0
        for <netdev@vger.kernel.org>; Mon, 31 Jul 2017 07:47:58 -0700 (PDT)
In-Reply-To: <597EF067.1090605@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/31/2017 01:55 AM, Daniel Borkmann wrote:
> On 07/30/2017 03:28 PM, Levin, Alexander (Sasha Levin) wrote:
>> On Mon, Jul 17, 2017 at 09:30:02AM -0700, John Fastabend wrote:
>>> @@ -341,9 +368,11 @@ static int dev_map_update_elem(struct bpf_map *map, void *key, void *value,
>>>      * Remembering the driver side flush operation will happen before the
>>>      * net device is removed.
>>>      */
>>> +    mutex_lock(&dev_map_list_mutex);
>>>     old_dev = xchg(&dtab->netdev_map[i], dev);
>>>     if (old_dev)
>>>         call_rcu(&old_dev->rcu, __dev_map_entry_free);
>>> +    mutex_unlock(&dev_map_list_mutex);
>>>
>>>     return 0;
>>> }
>>
>> This function gets called under rcu critical section, where we can't grab mutexes:
> 
> Agree, same goes for the delete callback that mutex is not allowed
> in this context. If I recall, this was for the devmap netdev notifier
> in order to check whether we need to purge dev entries from the map,
> so that the device can be unregistered gracefully. Given that devmap
> ops like update/delete are only allowed from user space, we could
> look into whether this map type actually needs to hold RCU at all
> here, or other option is to try and get rid of the mutex altogether.
> John, could you take a look for a fix?
> 
> Thanks a lot,
> Daniel
> 

I'll work up a fix today/tomorrow. Thanks.
