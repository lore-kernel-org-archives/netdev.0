From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: Re: [PATCH v3 net-next 1/4] net: implement support for low latency
 socket polling
Date: Tue, 21 May 2013 10:28:55 +0300
Message-ID: <519B2237.20204@linux.intel.com>
References: <20130520101552.14133.45953.stgit@ladj378.jer.intel.com>  <20130520101601.14133.874.stgit@ladj378.jer.intel.com> <1369063764.3301.182.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Dave Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	e1000-devel@lists.sourceforge.net,
	Willem de Bruijn <willemb@google.com>,
	Andi Kleen <andi@firstfloor.org>, HPA <hpa@zytor.com>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1369063764.3301.182.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 20/05/2013 18:29, Eric Dumazet wrote:
> On Mon, 2013-05-20 at 13:16 +0300, Eliezer Tamir wrote:
---
>> +static inline void skb_mark_ll(struct sk_buff *skb, struct napi_struct *napi)
>> +{
>> +	skb->dev_ref = napi;
>> +}
>> +
>> +static inline void sk_mark_ll(struct sock *sk, struct sk_buff *skb)
>> +{
>> +	sk->dev_ref = skb->dev_ref;
>> +}
>
> I do not see why it's safe to keep a pointer to a napi object without
> taking a reference, or something to prevent object being removed.
>
> Using a genid might be enough. (some counter incremented every time a
> napi is dismantled)

I really like this approach and I tried it.
The main problem I had is that you need to increase the size of the skb 
to store the generation id unless you stuff it in the flags2 bitfield.
There appear to be only 7 useful bit left there.
Is it OK to use them all up?


> Alternatively, use a napi_id instead of a pointer.

I'm not sure I understand what you propose.

-Eliezer
