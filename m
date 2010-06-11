From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 2/2] x86: Align skb w/ start of cache line
 on newer core 2/Xeon Arch
Date: Thu, 10 Jun 2010 22:20:06 -0700 (PDT)
Message-ID: <20100610.222006.242136751.davem@davemloft.net>
References: <20100602222506.12962.49240.stgit@localhost.localdomain>
	<1275518650.29413.43.camel@edumazet-laptop>
	<80769D7B14936844A23C0C43D9FBCF0F2562CD2555@orsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, jeffrey.t.kirsher@intel.com,
	mingo@redhat.com, tglx@linutronix.de, hpa@zytor.com,
	x86@kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, gospo@redhat.com
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47128
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753456Ab0FKFT5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jun 2010 01:19:57 -0400
In-Reply-To: <80769D7B14936844A23C0C43D9FBCF0F2562CD2555@orsmsx501.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Duyck, Alexander H" <alexander.h.duyck@intel.com>
Date: Wed, 2 Jun 2010 16:55:16 -0700

> Eric Dumazet wrote:
>> 
>> But... L1_CACHE_BYTES is 64 on MCORE2, so this matches current
>> NET_SKB_PAD definition...
>> 
>> #ifndef NET_SKB_PAD
>> #define NET_SKB_PAD 64
>> #endif
>
> I admit the current definition is redundant, but NET_SKB_PAD had
> been 32 until your recent change of the value, and prior to 2.6.30
> the value was 16.  If the value were to change again it would
> silently break the cacheline alignment which is provided by this
> patch.  If we were to define NET_SKB_PAD using L1_CACHE_BYTES in
> skbuff.h then I might be more inclined to to pull the NET_SKB_PAD
> change, but right now I would prefer to treat NET_SKB_PAD as a magic
> number that coincidently is the same size as the L1 cache on MCORE2.

Eric, why don't we do that?  Make NET_SKB_PAD's define L1_CACHE_BYTES.

Reading the comments you added when the default value was changed to
64, this seems to even be your overall intent. :-)
