From: David Miller <davem@davemloft.net>
Subject: Re: [net-next bugfix] net, rps: fix build failure when CONFIG_RPS
 isn't set
Date: Tue, 31 Dec 2013 15:58:39 -0500 (EST)
Message-ID: <20131231.155839.537215284284145712.davem@davemloft.net>
References: <1388521861-17410-1-git-send-email-zwu.kernel@gmail.com>
	<20131231.155459.1250298598367444558.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com,
	fengguang.wu@intel.com, wuzhy@linux.vnet.ibm.com
To: zwu.kernel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36254 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756215Ab3LaU6k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Dec 2013 15:58:40 -0500
In-Reply-To: <20131231.155459.1250298598367444558.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Tue, 31 Dec 2013 15:54:59 -0500 (EST)

> From: Zhi Yong Wu <zwu.kernel@gmail.com>
> Date: Wed,  1 Jan 2014 04:31:01 +0800
> 
>> @@ -846,12 +846,16 @@ static inline void sock_rps_reset_flow_hash(__u32 hash)
>>  
>>  static inline void sock_rps_record_flow(const struct sock *sk)
>>  {
>> +#ifdef CONFIG_RPS
>>  	sock_rps_record_flow_hash(sk->sk_rxhash);
>> +#endif
>>  }
> 
> Why is this necessary?  sock_rps_record_flow_hash() is provided
> unconditionally, regardless of CONFIG_RPS.
> 
> I'm not applying this, it doesn't make any sense.  Either there is
> no build failure, or the existing CONFIG_RPS ifdef inside of the
> implementation of sock_rps_record_flow_hash() is bogus.

Ok, if you had actually provided the build failure log message I'd be
able to evaluate this patch much better.

The real issue is the lack of sk_rxhash when RPS is not enabled.

I'm going to apply this with the build failure message mentioned.
