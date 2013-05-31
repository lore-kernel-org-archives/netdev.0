From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH net-next 02/12] tipc: Add "max_ports" configuration parameter
Date: Fri, 31 May 2013 13:48:56 -0400
Message-ID: <51A8E288.9020206@windriver.com>
References: <1369942577-39563-1-git-send-email-paul.gortmaker@windriver.com> <1369942577-39563-3-git-send-email-paul.gortmaker@windriver.com> <20130530.154925.298481337221579707.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <jon.maloy@ericsson.com>,
	<ying.xue@windriver.com>, <erik.hugne@ericsson.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:52425 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753696Ab3EaRsj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 May 2013 13:48:39 -0400
In-Reply-To: <20130530.154925.298481337221579707.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13-05-30 06:49 PM, David Miller wrote:
> From: Paul Gortmaker <paul.gortmaker@windriver.com>
> Date: Thu, 30 May 2013 15:36:07 -0400
> 
>> From: Erik Hugne <erik.hugne@ericsson.com>
>>
>> Introduce the "max_ports" module parameter, which allows the maximum
>> number of ports supported by TIPC to be changed from the default value
>> at boot, or at module load time. Because of the way the port reference
>> table is structured and initiated, this value must be known at module
>> start time, and can not be changed later.
>>
>> Until now this value has been set via a macro, and hence things
>> have to be recompiled if the value is to be changed. The Kconfig
>> knob and the dead code intended to change this parameter at runtime
>> are dropped.
>>
>> Considering TIPC node addresses are unique on the entire node, the
>> 64k port limit has proven to be a little too strict.  We increase the
>> allowed max to 128k. This is safe since the protocol headers allow
>> for up to 2^32 -1 ports.
>>
>> Usage for module: "insmod tipc.ko max_ports=<value>" ; at boot, append
>> "tipc.max_ports=<value>" to the kernel command line.
>>
>> Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
>> Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
>> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
> 
> View compile time constants and module parameters as artificial
> limits, they are terrible and unnecessary.

I can't argue with that; I was thinking that the module param was
better than a recompile, but as you say, not having it at all is
yet better again.  I'll drop this patch, and if the reimplementation
isn't ready before 3.10-rc6, I'll just resend the series without it.

Thanks,
Paul.
--

> 
> There is no reason you cannot restructure this table so that you
> can dynamically size it at run time.
> 
> Please reimplement it in that way.
> 
> Thanks.
> 
