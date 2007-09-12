From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [PATCH] veth: Cleanly handle a missing peer_tb argument on creation.
Date: Wed, 12 Sep 2007 18:49:08 +0400
Message-ID: <46E7FC64.5030604@openvz.org>
References: <m17imwaumb.fsf@ebiederm.dsl.xmission.com>	<46E7F466.1060704@openvz.org> <m1odg89byw.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:53418 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966819AbXILOvt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Sep 2007 10:51:49 -0400
In-Reply-To: <m1odg89byw.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric W. Biederman wrote:
> Pavel Emelyanov <xemul@openvz.org> writes:
> 
>>> +	}
>>>  
>>> -		tbp = peer_tb;
>>> -	} else
>>> -		tbp = tb;
>> The intention of this part was to get the same parameters for
>> peer as for the first device if no "peer" argument was specified
>> for ip utility. Does it still work?
> 
> I know it is problematic because we try to assign the same name
> to both network devices, if we assign a name to the primary
> network device.  That can't work.

This can - as you can see I reallocate the name lower.

> Beyond that I had some really weird crashes while testing this
> piece of code, especially when I did not specify a peer parameter.

Can you please give me the exact command that caused an oops.
I try simple ip link add type veth and everything is just fine.

> So it was just easier to avoid the problem with this patch then
> to completely root cause it.

Let me handle this problem. AFAIR this was one of wishes from 
Patrick that we make two equal devices in case peer is not given, 
not just the default peer.

> I think the easiest semantic is to not have any peer parameters
> if they were not specified, then to try and to figure out which
> subset of parameters to copy.  If I hadn't been getting weird
> kernel crashes I would not have cared.
> 
> Eric
> 

Thanks,
Pavel
