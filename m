From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: don't dereference ptr before leaving
 _sctp_walk_{params,errors}()
Date: Thu, 13 Jul 2017 13:44:43 -0700 (PDT)
Message-ID: <20170713.134443.1912348414766536226.davem@davemloft.net>
References: <20170713181034.41123-1-glider@google.com>
        <20170713.113206.177363709000549854.davem@davemloft.net>
        <CAG_fn=VJQUG1RveUyXDVuZmMrBz3DZLrar3pEKKJegyi3mYbaA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dvyukov@google.com, kcc@google.com, edumazet@google.com,
        lucien.xin@gmail.com, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: glider@google.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAG_fn=VJQUG1RveUyXDVuZmMrBz3DZLrar3pEKKJegyi3mYbaA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexander Potapenko <glider@google.com>
Date: Thu, 13 Jul 2017 21:28:39 +0200

> On Thu, Jul 13, 2017 at 8:32 PM, David Miller <davem@davemloft.net> wrote:
>> struct sctp_paramhdr {
>>         __be16 type;
>>         __be16 length;
>> };
>>
>> typedef struct sctp_errhdr {
>>         __be16 cause;
>>         __be16 length;
>>         __u8  variable[0];
>> } sctp_errhdr_t;
 ...
>> Something like:
>>
>>         pos.v + offsetof(pos.v, length) + sizeof(pos.v->length) <= (void *) chunk + end
> 
> Do we need to bother about truncated structures? Shouldn't it be
> enough to check that there's at least sizeof(struct sctp_paramhdr)
> bytes left then?

With the zero length array at the end, it's arguable what the "size"
of such a thing is.

That's why I tried to be explicit with the length field.
