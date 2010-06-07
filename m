From: Mitchell Erblich <erblichs@earthlink.net>
Subject: Re: [RFC PATCH v7 01/19] Add a new structure for skb buffer from external.
Date: Mon, 7 Jun 2010 01:17:02 -0700
Message-ID: <40119F5E-A745-4C50-8053-D5A701266AD5@earthlink.net>
References: <1275732899-5423-1-git-send-email-xiaohui.xin@intel.com> <20100606161348.427822fb@nehalam> <87pr03gu1c.fsf@basil.nowhere.org>
Mime-Version: 1.0 (Apple Message framework v1078)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Stephen Hemminger <shemminger@vyatta.com>, xiaohui.xin@intel.com,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, mingo@elte.hu,
	davem@davemloft.net, herbert@gondor.apana.org.au,
	jdike@linux.intel.com
To: Andi Kleen <andi@firstfloor.org>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <87pr03gu1c.fsf@basil.nowhere.org>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Jun 7, 2010, at 12:51 AM, Andi Kleen wrote:

> Stephen Hemminger <shemminger@vyatta.com> writes:
> 
>> Still not sure this is a good idea for a couple of reasons:
>> 
>> 1. We already have lots of special cases with skb's (frags and fraglist),
>>   and skb's travel through a lot of different parts of the kernel.  So any
>>   new change like this creates lots of exposed points for new bugs. Look
>>   at cases like MD5 TCP and netfilter, and forwarding these SKB's to ipsec
>>   and ppp and ...
>> 
>> 2. SKB's can have infinite lifetime in the kernel. If these buffers come from
>>   a fixed size pool in an external device, they can easily all get tied up
>>   if you have a slow listener. What happens then?
> 
> 3. If they come from an internal pool what happens when the kernel runs 
> low on memory? How is that pool balanced against other kernel
> memory users?
> 
> -Andi
> 
> -- 
> ak@linux.intel.com -- Speaking for myself only.

In general,

When an internal pool is created/used, their SHOULD be a reason.
Maybe, to keep allocation latency to a min, OR ...

Now IMO, 

internal pool objects should have a ref count and
if that count is 0, then under memory pressure and/or num 
of objects are above a high water mark, then they are freed,

OR if there is a last reference age field, then the object is to be 
cleaned if dirty, then freed,  

Else, the pool is allowed to grow if the number of objects in the
pool is below a set max (max COULD equal Infinity).



Mitchell Erblich