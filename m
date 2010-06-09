From: "Xin, Xiaohui" <xiaohui.xin@intel.com>
Subject: RE: [RFC PATCH v7 01/19] Add a new structure for skb buffer from
 external.
Date: Wed, 9 Jun 2010 17:22:12 +0800
Message-ID: <F2E9EB7348B8264F86B6AB8151CE2D791100848F73@shsmsx502.ccr.corp.intel.com>
References: <1275732899-5423-1-git-send-email-xiaohui.xin@intel.com>
 <20100606161348.427822fb@nehalam> <87pr03gu1c.fsf@basil.nowhere.org>
 <40119F5E-A745-4C50-8053-D5A701266AD5@earthlink.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"mst@redhat.com" <mst@redhat.com>, "mingo@elte.hu" <mingo@elte.hu>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>,
	"jdike@linux.intel.com" <jdike@linux.intel.com>
To: Mitchell Erblich <erblichs@earthlink.net>,
	Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:54361 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756924Ab0FIJWl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jun 2010 05:22:41 -0400
In-Reply-To: <40119F5E-A745-4C50-8053-D5A701266AD5@earthlink.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Mitchell Erblich [mailto:erblichs@earthlink.net]
>Sent: Monday, June 07, 2010 4:17 PM
>To: Andi Kleen
>Cc: Stephen Hemminger; Xin, Xiaohui; netdev@vger.kernel.org; kvm@vger.kernel.org;
>linux-kernel@vger.kernel.org; mst@redhat.com; mingo@elte.hu; davem@davemloft.net;
>herbert@gondor.apana.org.au; jdike@linux.intel.com
>Subject: Re: [RFC PATCH v7 01/19] Add a new structure for skb buffer from external.
>
>
>On Jun 7, 2010, at 12:51 AM, Andi Kleen wrote:
>
>> Stephen Hemminger <shemminger@vyatta.com> writes:
>>
>>> Still not sure this is a good idea for a couple of reasons:
>>>
>>> 1. We already have lots of special cases with skb's (frags and fraglist),
>>>   and skb's travel through a lot of different parts of the kernel.  So any
>>>   new change like this creates lots of exposed points for new bugs. Look
>>>   at cases like MD5 TCP and netfilter, and forwarding these SKB's to ipsec
>>>   and ppp and ...
>>>
>>> 2. SKB's can have infinite lifetime in the kernel. If these buffers come from
>>>   a fixed size pool in an external device, they can easily all get tied up
>>>   if you have a slow listener. What happens then?
>>
>> 3. If they come from an internal pool what happens when the kernel runs
>> low on memory? How is that pool balanced against other kernel
>> memory users?
>>
>> -Andi
>>
>> --
>> ak@linux.intel.com -- Speaking for myself only.
>
>In general,
>
>When an internal pool is created/used, their SHOULD be a reason.
>Maybe, to keep allocation latency to a min, OR ...
>
The internal pool here is a collection of user buffers submitted
by guest virtio-net driver. Guest put buffers here and driver get
buffers from it. If guest submit more buffers then driver needs,
we need somewhere to put the buffers, it's the internal pool here
to deal with. 

>Now IMO,
>
>internal pool objects should have a ref count and
>if that count is 0, then under memory pressure and/or num
>of objects are above a high water mark, then they are freed,
>
>OR if there is a last reference age field, then the object is to be
>cleaned if dirty, then freed,
>
>Else, the pool is allowed to grow if the number of objects in the
>pool is below a set max (max COULD equal Infinity).

Thanks for the thoughts.

Basically, the size of the internal pool is not decided by the pool itself,
To add/delete the objects in the pool is not a task of the pool itself too. 
It's decided by guest virtio-net driver and vhost-net driver both, and 
decided by the guest receive speed and submit speed.
The max size of the pool is limited by the virtqueue buffer numbers.

Thanks
Xiaohui

>
>
>
>Mitchell Erblich
