From: Cong Wang <amwang@redhat.com>
Subject: Re: [RFC Patch] net: reserve ports for applications using fixed port
 numbers
Date: Fri, 05 Feb 2010 14:01:43 +0800
Message-ID: <4B6BB447.8080806@redhat.com>
References: <20100204.094110.64247447.davem@davemloft.net> <20100204.135639.69720709.davem@davemloft.net> <201002050041.o150fCO8081208@www262.sakura.ne.jp> <201002050305.22227.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	davem@davemloft.net, linux-kernel@vger.kernel.org,
	eric.dumazet@gmail.com, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org, nhorman@tuxdriver.com,
	linux-sctp@vger.kernel.org
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8091 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751918Ab0BEF6e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Feb 2010 00:58:34 -0500
In-Reply-To: <201002050305.22227.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Octavian Purdila wrote:
> On Friday 05 February 2010 02:41:12 you wrote:
>> David Miller wrote:
>>>> Octavian Purdila wrote:
>>>>> int inet_is_reserved_local_port(int port)
>>>>> {
>>>>> 	if (test_bit(port, reserved_ports))
>>>>> 		return 1;
>>>>> 	return 0;
>>>>> }
>>>> Above check is exactly what I'm doing in the LSM hook.
>>> But his version can be done inline in 2 or 3 instructions.
>>>
>>> An LSM hook will result in an indirect function call,
>>> all live registers spilled to the stack, then all of
>>> those reloaded when the function returns.
>>>
>>> It will be much more expensive.
>> If you can accept his version, I want to use his version (with an interface
>>  for updating above "reserved_ports" by not only root user's sysctl() but
>>  also MAC's policy configuration).
>>
> 
> I think that simply using an interface to update the reserved_ports from MAC 
> policy configuration module wouldn't work, as root will be able to modify the 
> policy via sysctl.
> 
> I think that we might need to:
> 
> a) have a reserved_port updater
> 
> b) put a LSM hook into that
> 
> c) use the reserved_port updater from sysctl
> 
> 

Ideally, you'd provide an interface for port allocator to use, so
doing port reservation will be easier.

Thanks.


