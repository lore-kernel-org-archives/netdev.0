From: "Xin, Xiaohui" <xiaohui.xin@intel.com>
Subject: RE: [PATCH v15 00/17] Provide a zero-copy method on KVM virtio-net.
Date: Wed, 17 Nov 2010 16:09:12 +0800
Message-ID: <F2E9EB7348B8264F86B6AB8151CE2D7934FF8D1D57@shsmsx502.ccr.corp.intel.com>
References: <20101109.091516.112581012.davem@davemloft.net>
	<1289381008-5484-1-git-send-email-xiaohui.xin@intel.com>
 <20101110.094641.193701683.davem@davemloft.net>
 <F2E9EB7348B8264F86B6AB8151CE2D793498A31E75@shsmsx502.ccr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"mst@redhat.com" <mst@redhat.com>, "mingo@elte.hu" <mingo@elte.hu>,
	"herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>,
	"jdike@linux.intel.com" <jdike@linux.intel.com>
To: "Xin, Xiaohui" <xiaohui.xin@intel.com>,
	David Miller <davem@davemloft.net>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <F2E9EB7348B8264F86B6AB8151CE2D793498A31E75@shsmsx502.ccr.corp.intel.com>
Content-Language: en-US
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>-----Original Message-----
>From: kvm-owner@vger.kernel.org [mailto:kvm-owner@vger.kernel.org] On Behalf Of Xin,
>Xiaohui
>Sent: Thursday, November 11, 2010 4:28 PM
>To: David Miller
>Cc: netdev@vger.kernel.org; kvm@vger.kernel.org; linux-kernel@vger.kernel.org;
>mst@redhat.com; mingo@elte.hu; herbert@gondor.apana.org.au; jdike@linux.intel.com
>Subject: RE: [PATCH v15 00/17] Provide a zero-copy method on KVM virtio-net.
>
>>-----Original Message-----
>>From: David Miller [mailto:davem@davemloft.net]
>>Sent: Thursday, November 11, 2010 1:47 AM
>>To: Xin, Xiaohui
>>Cc: netdev@vger.kernel.org; kvm@vger.kernel.org; linux-kernel@vger.kernel.org;
>>mst@redhat.com; mingo@elte.hu; herbert@gondor.apana.org.au; jdike@linux.intel.com
>>Subject: Re: [PATCH v15 00/17] Provide a zero-copy method on KVM virtio-net.
>>
>>From: xiaohui.xin@intel.com
>>Date: Wed, 10 Nov 2010 17:23:28 +0800
>>
>>> From: Xin Xiaohui <xiaohui.xin@intel.com>
>>>
>>>>2) The idea to key off of skb->dev in skb_release_data() is
>>>>   fundamentally flawed since many actions can change skb->dev on you,
>>>>   which will end up causing a leak of your external data areas.
>>>
>>> How about this one? If the destructor_arg is not a good candidate,
>>> then I have to add an apparent field in shinfo.
>>
>>If destructor_arg is actually a net_device pointer or similar,
>>you will need to take a reference count on it or similar.
>>
>Do you mean destructor_arg will be consumed by other user?
>If that case, may I add a new structure member in shinfo?
>Thus only zero-copy will use it, and no need for the reference count.
>
How about this? It really needs somewhere to track the external data area,
and if something wrong with it, we can also release the data area. We think 
skb_release_data() is the right place to deal with it. If I understood right,
that destructor_arg will be used by other else that why reference count is
needed, then how about add a new structure member in shinfo?

Thanks
Xiaohui 

>>Which means --> good bye performance especially on SMP.
>>
>>You're going to be adding new serialization points and at
>>least two new atomics per packet.
>--
>To unsubscribe from this list: send the line "unsubscribe kvm" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
