From: "Xin, Xiaohui" <xiaohui.xin@intel.com>
Subject: RE: [PATCH v12 06/17] Use callback to deal with skb_release_data()
 specially.
Date: Mon, 11 Oct 2010 15:06:05 +0800
Message-ID: <F2E9EB7348B8264F86B6AB8151CE2D793064B2A9D8@shsmsx502.ccr.corp.intel.com>
References: <1285855474-12110-1-git-send-email-xiaohui.xin@intel.com>
	<59d8a50047ee01e26658fd676d26c0162b79e5fd.1285853725.git.xiaohui.xin@intel.com>
	<f2bf65a8a7676bbd3e8a749ae93d99e88671d35d.1285853725.git.xiaohui.xin@intel.com>
 <20101001.001439.85411154.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"mst@redhat.com" <mst@redhat.com>, "mingo@elte.hu" <mingo@elte.hu>,
	"herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>,
	"jdike@linux.intel.com" <jdike@linux.intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101001.001439.85411154.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>-----Original Message-----
>From: David Miller [mailto:davem@davemloft.net]
>Sent: Friday, October 01, 2010 3:15 PM
>To: Xin, Xiaohui
>Cc: netdev@vger.kernel.org; kvm@vger.kernel.org; linux-kernel@vger.kernel.org;
>mst@redhat.com; mingo@elte.hu; herbert@gondor.apana.org.au; jdike@linux.intel.com
>Subject: Re: [PATCH v12 06/17] Use callback to deal with skb_release_data() specially.
>
>From: xiaohui.xin@intel.com
>Date: Thu, 30 Sep 2010 22:04:23 +0800
>
>> @@ -197,10 +197,11 @@ struct skb_shared_info {
>>  	union skb_shared_tx tx_flags;
>>  	struct sk_buff	*frag_list;
>>  	struct skb_shared_hwtstamps hwtstamps;
>> -	skb_frag_t	frags[MAX_SKB_FRAGS];
>>  	/* Intermediate layers must ensure that destructor_arg
>>  	 * remains valid until skb destructor */
>>  	void *		destructor_arg;
>> +
>> +	skb_frag_t	frags[MAX_SKB_FRAGS];
>>  };
>>
>>  /* The structure is for a skb which pages may point to
>
>Why are you moving frags[] to the end like this?

That's to avoid the new cache miss caused by using destructor_arg in data path
like skb_release_data().
That's based on the comment from Eric Dumazet on v7 patches.

Thanks
Xiaohui
