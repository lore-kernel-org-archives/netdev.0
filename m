From: David Miller <davem@davemloft.net>
Subject: Re: Moving frags and SKBTX_DEV_ZEROCOPY skbs
Date: Wed, 14 May 2014 13:42:47 -0400 (EDT)
Message-ID: <20140514.134247.1863750484757866783.davem@davemloft.net>
References: <53737266.5040601@citrix.com>
	<1400077432.7973.85.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zoltan.kiss@citrix.com, netdev@vger.kernel.org,
	xen-devel@lists.xenproject.org, kvm@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1400077432.7973.85.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 14 May 2014 07:23:52 -0700

> On Wed, 2014-05-14 at 14:40 +0100, Zoltan Kiss wrote:
>> Hi,
>> 
>> Recently I've investigated issues around SKBTX_DEV_ZEROCOPY skbs where 
>> the frags list were modified. I came across this function skb_shift(), 
>> which moves frags between skbs. And there are a lot more of such kind, 
>> skb_split or skb_try_coalesce, for example.
>> It could be a dangerous thing if a frag is referenced from an skb which 
>> doesn't have the original destructor_arg, and to avoid that 
>> skb_orphan_frags should be called. Although probably these functions are 
>> not normally touched in usual usecases, I think it would be useful to 
>> review core skb functions proactively and add an skb_orphan_frags 
>> everywhere where the frags could be referenced from other places.
>> Any opinion about this?
> 
> 
> For skb_shift(), it is currently used from tcp stack only, where
> this SKBTX_DEV_ZEROCOPY thing is not used, so I do not think there is a
> bug for the moment.
> 
> I already gave a patch for skb_try_coalesce() : For this one we do not
> wan skb_orphan_frags() overhead. Its simply better in this case to
> abort.

Eric can you please submit this formally?  It is second time I've seen
it posted as RFC :-)
