From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: Re: [PATCH net-next] net: Cleanup skb cloning by adding SKB_FCLONE_FREE
Date: Thu, 2 Oct 2014 09:36:45 -0700
Message-ID: <CAGK4HS_8QFvvwEwJLhT6c2pE9qVVo__P4e3Qm864rqUu5Y+Vag@mail.gmail.com>
References: <1412231620-3767-1-git-send-email-subramanian.vijay@gmail.com>
	<1412249728.16704.76.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:56660 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751056AbaJBQgq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2014 12:36:46 -0400
Received: by mail-wi0-f179.google.com with SMTP id d1so4706625wiv.6
        for <netdev@vger.kernel.org>; Thu, 02 Oct 2014 09:36:45 -0700 (PDT)
In-Reply-To: <1412249728.16704.76.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sure. Will resend V2 shortly.

Vijay

On 2 October 2014 04:35, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2014-10-01 at 23:33 -0700, Vijay Subramanian wrote:
>> SKB_FCLONE_UNAVAILABLE has overloaded meaning depending on type of skb.
>> 1: If skb is allocated from head_cache, it indicates fclone is not available.
>> 2: If skb is a companion fclone skb (allocated from fclone_cache), it indicates
>> it is available to be used.
>>
>> To avoid confusion for case 2 above, this patch  replaces
>> SKB_FCLONE_UNAVAILABLE with SKB_FCLONE_FREE where appropriate. For fclone
>> companion skbs, this indicates it is free for use.
>>
>> SKB_FCLONE_UNAVAILABLE will now simply indicate skb is from head_cache and
>> cannot / will not have a companion fclone.
>>
>> Signed-off-by: Vijay Subramanian <subramanian.vijay@gmail.com>
>> ---
>>  include/linux/skbuff.h | 3 ++-
>>  net/core/skbuff.c      | 8 ++++----
>>  2 files changed, 6 insertions(+), 5 deletions(-)
>>
>> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
>> index 7c5036d..6c3fb9a 100644
>> --- a/include/linux/skbuff.h
>> +++ b/include/linux/skbuff.h
>> @@ -339,9 +339,10 @@ struct skb_shared_info {
>>
>>
>>  enum {
>> -     SKB_FCLONE_UNAVAILABLE,
>> +     SKB_FCLONE_UNAVAILABLE, /* skb has no fclone */
>>       SKB_FCLONE_ORIG,
>>       SKB_FCLONE_CLONE,
>> +     SKB_FCLONE_FREE,        /* this fclone skb is available */
>>  };
>>
> Please comment all the states, now there is no ambiguity ?
>
>
>
