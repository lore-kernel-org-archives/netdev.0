From: David Miller <davem@davemloft.net>
Subject: Re: [net-next bugfix] net, rps: fix build failure when CONFIG_RPS
 isn't set
Date: Tue, 31 Dec 2013 16:08:26 -0500 (EST)
Message-ID: <20131231.160826.966509294799970296.davem@davemloft.net>
References: <1388521861-17410-1-git-send-email-zwu.kernel@gmail.com>
	<52C33F26.8070609@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zwu.kernel@gmail.com, netdev@vger.kernel.org, therbert@google.com,
	fengguang.wu@intel.com, wuzhy@linux.vnet.ibm.com
To: sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36300 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754838Ab3LaVI2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Dec 2013 16:08:28 -0500
In-Reply-To: <52C33F26.8070609@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Wed, 01 Jan 2014 01:03:18 +0300

> Hello.
> 
> On 12/31/2013 11:31 PM, Zhi Yong Wu wrote:
> 
>> From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
> 
>> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
>> Signed-off-by: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
>> ---
>>   include/net/sock.h |    4 ++++
>>   1 files changed, 4 insertions(+), 0 deletions(-)
> 
>> diff --git a/include/net/sock.h b/include/net/sock.h
>> index 8ee90ad..bd716b6 100644
>> --- a/include/net/sock.h
>> +++ b/include/net/sock.h
>> @@ -846,12 +846,16 @@ static inline void
>> sock_rps_reset_flow_hash(__u32 hash)
>>
>>   static inline void sock_rps_record_flow(const struct sock *sk)
>>   {
>> +#ifdef CONFIG_RPS
>>   	sock_rps_record_flow_hash(sk->sk_rxhash);
>> +#endif
>>   }
>>
>>   static inline void sock_rps_reset_flow(const struct sock *sk)
>>   {
>> +#ifdef CONFIG_RPS
>>   	sock_rps_reset_flow_hash(sk->sk_rxhash);
>> +#endif
>>   }
> 
>    A lot better style would be:

No, the functions have to be available, but have a NOP implementation.
