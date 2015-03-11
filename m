From: Ying Xue <ying.xue@windriver.com>
Subject: Re: [PATCH net-next v2] tipc: fix undefined __ipv6_sock_mc_join compile
 error
Date: Wed, 11 Mar 2015 11:11:37 +0800
Message-ID: <54FFB269.10009@windriver.com>
References: <1425976885-18258-1-git-send-email-ying.xue@windriver.com>	<CA+FuTSdxmae0DnNnQdCgCdaThVtZ1raqEg9z6XpHE5N9u5MCfw@mail.gmail.com> <20150310.124742.2005589544373604240.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <jon.maloy@ericsson.com>, <Paul.Gortmaker@windriver.com>,
	<erik.hugne@ericsson.com>, <fengguang.wu@intel.com>,
	<netdev@vger.kernel.org>, <tipc-discussion@lists.sourceforge.net>,
	<kbuild-all@01.org>
To: David Miller <davem@davemloft.net>, <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:59929 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750810AbbCKDMF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 23:12:05 -0400
In-Reply-To: <20150310.124742.2005589544373604240.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/11/2015 12:47 AM, David Miller wrote:
> From: Willem de Bruijn <willemb@google.com>
> Date: Tue, 10 Mar 2015 11:41:03 -0400
> 
>> On Tue, Mar 10, 2015 at 4:41 AM, Ying Xue <ying.xue@windriver.com> wrote:
>>> @@ -5,6 +5,7 @@
>>>  menuconfig TIPC
>>>         tristate "The TIPC Protocol"
>>>         depends on INET
>>> +       depends on (IPV6 || IPV6=n)
>>
>> Should this be limited to TIPC_MEDIA_UDP?
> 
> I think it should.
> 
> 

My first thought is also same as you. But when the dependency like (IPV6 ||
IPV6=n) is enforced to TIPC_MEDIA_UDP, it doesn't work in the below case:

IPV6=m and TIPC=Y.

In above condition, TIPC_MEDIA_UDP is still set to "Y".

However, if I change the dependency to IPV6=y and IPV6=n, and allow it to limit
TIPC_MEDIA_UDP, TIPC modules can be built successfully in kinds of cases.

Thank for your review! Please wait a moment, and I will fix it in next version.

Regards,
Ying
