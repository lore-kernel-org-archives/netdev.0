From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: [PATCH 2/2] [SKBUFF] introduce tr_hdr(skb)
Date: Wed, 06 Oct 2004 16:18:49 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41644519.6040405@conectiva.com.br>
References: <41643C40.8070605@conectiva.com.br> <20041006185835.GB19714@rei.reeler.org> <4164424E.6000504@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, "David S. Miller" <davem@redhat.com>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
In-Reply-To: <4164424E.6000504@conectiva.com.br>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Arnaldo Carvalho de Melo wrote:
> 
> 
> Thomas Graf wrote:
> 
>> * Arnaldo Carvalho de Melo <41643C40.8070605@conectiva.com.br> 
>> 2004-10-06 15:41
>>
>>> -        trh = (struct trh_hdr *)skb_push(skb, sizeof(*trh));
>>> +        skb->mac.raw = skb_push(skb, sizeof(*trh));
>>> +        trh = tr_hdr(skb);
>>>         trh->ac = AC;
>>>         trh->fc = LLC_FRAME;
>>>         if (sa)
>>> @@ -51,7 +52,6 @@
>>>             memcpy(trh->daddr, da, dev->addr_len);
>>>             tr_source_route(skb, trh, dev);
>>>         }
>>> -        skb->mac.raw = skb->data;
>>
>>
>>
>> Are you sure the bevhaviour is the same? There is an skb_pull
>> in tr_source_route so skb->data gets modified.
>>
> 
> 
> Thanks for reviewing, checking...
> 
> 

You're right, if tr_source_route is called, skb->mac.raw has to be set
to skb->data, to maintain the old behaviour, if it is right? Oh well,
as I said there aren't many people using Token Ring, let alone LLC over
token ring, I'll be posting a patch in some minutes.

- Arnaldo
