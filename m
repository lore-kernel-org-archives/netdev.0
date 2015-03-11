From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] tipc: fix undefined __ipv6_sock_mc_join
 compile error
Date: Wed, 11 Mar 2015 00:05:12 -0400 (EDT)
Message-ID: <20150311.000512.1167662110194290318.davem@davemloft.net>
References: <CA+FuTSdxmae0DnNnQdCgCdaThVtZ1raqEg9z6XpHE5N9u5MCfw@mail.gmail.com>
	<20150310.124742.2005589544373604240.davem@davemloft.net>
	<54FFB269.10009@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: willemb@google.com, jon.maloy@ericsson.com,
	Paul.Gortmaker@windriver.com, erik.hugne@ericsson.com,
	fengguang.wu@intel.com, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net, kbuild-all@01.org
To: ying.xue@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37641 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750895AbbCKEFO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 00:05:14 -0400
In-Reply-To: <54FFB269.10009@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>
Date: Wed, 11 Mar 2015 11:11:37 +0800

> On 03/11/2015 12:47 AM, David Miller wrote:
>> From: Willem de Bruijn <willemb@google.com>
>> Date: Tue, 10 Mar 2015 11:41:03 -0400
>> 
>>> On Tue, Mar 10, 2015 at 4:41 AM, Ying Xue <ying.xue@windriver.com> wrote:
>>>> @@ -5,6 +5,7 @@
>>>>  menuconfig TIPC
>>>>         tristate "The TIPC Protocol"
>>>>         depends on INET
>>>> +       depends on (IPV6 || IPV6=n)
>>>
>>> Should this be limited to TIPC_MEDIA_UDP?
>> 
>> I think it should.
>> 
>> 
> 
> My first thought is also same as you. But when the dependency like (IPV6 ||
> IPV6=n) is enforced to TIPC_MEDIA_UDP, it doesn't work in the below case:
> 
> IPV6=m and TIPC=Y.
> 
> In above condition, TIPC_MEDIA_UDP is still set to "Y".

It's because TIPC_MEDIA_UDP is bool, it needs to be a tristate.
