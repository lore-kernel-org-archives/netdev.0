From: "Xin, Xiaohui" <xiaohui.xin@intel.com>
Subject: RE: [RFC PATCH v7 01/19] Add a new structure for skb buffer from
 external.
Date: Wed, 9 Jun 2010 16:48:48 +0800
Message-ID: <F2E9EB7348B8264F86B6AB8151CE2D791100848F37@shsmsx502.ccr.corp.intel.com>
References: <1275732899-5423-1-git-send-email-xiaohui.xin@intel.com>
	<20100606161348.427822fb@nehalam> <87pr03gu1c.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"mst@redhat.com" <mst@redhat.com>, "mingo@elte.hu" <mingo@elte.hu>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>,
	"jdike@linux.intel.com" <jdike@linux.intel.com>
To: Andi Kleen <andi@firstfloor.org>,
	Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87pr03gu1c.fsf@basil.nowhere.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>-----Original Message-----
>From: kvm-owner@vger.kernel.org [mailto:kvm-owner@vger.kernel.org] On Behalf Of Andi
>Kleen
>Sent: Monday, June 07, 2010 3:51 PM
>To: Stephen Hemminger
>Cc: Xin, Xiaohui; netdev@vger.kernel.org; kvm@vger.kernel.org;
>linux-kernel@vger.kernel.org; mst@redhat.com; mingo@elte.hu; davem@davemloft.net;
>herbert@gondor.apana.org.au; jdike@linux.intel.com
>Subject: Re: [RFC PATCH v7 01/19] Add a new structure for skb buffer from external.
>
>Stephen Hemminger <shemminger@vyatta.com> writes:
>
>> Still not sure this is a good idea for a couple of reasons:
>>
>> 1. We already have lots of special cases with skb's (frags and fraglist),
>>    and skb's travel through a lot of different parts of the kernel.  So any
>>    new change like this creates lots of exposed points for new bugs. Look
>>    at cases like MD5 TCP and netfilter, and forwarding these SKB's to ipsec
>>    and ppp and ...
>>
>> 2. SKB's can have infinite lifetime in the kernel. If these buffers come from
>>    a fixed size pool in an external device, they can easily all get tied up
>>    if you have a slow listener. What happens then?
>
>3. If they come from an internal pool what happens when the kernel runs
>low on memory? How is that pool balanced against other kernel
>memory users?
>
The size of the pool is limited by the virtqueue capacity now.
If the virtqueue is really huge, then how to balance on memory is a problem.
I did not consider it clearly how to tune it dynamically currently...

>-Andi
>
>--
>ak@linux.intel.com -- Speaking for myself only.
>--
>To unsubscribe from this list: send the line "unsubscribe kvm" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
