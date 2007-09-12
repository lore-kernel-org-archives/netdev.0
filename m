From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] veth: Cleanly handle a missing peer_tb argument on creation.
Date: Wed, 12 Sep 2007 09:25:45 -0600
Message-ID: <m1ejh3aosm.fsf@ebiederm.dsl.xmission.com>
References: <m17imwaumb.fsf@ebiederm.dsl.xmission.com>
	<46E7F466.1060704@openvz.org>
	<m1odg89byw.fsf@ebiederm.dsl.xmission.com>
	<46E7FC64.5030604@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:46304 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933522AbXILP0S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 11:26:18 -0400
In-Reply-To: <46E7FC64.5030604@openvz.org> (Pavel Emelyanov's message of "Wed,
	12 Sep 2007 18:49:08 +0400")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pavel Emelyanov <xemul@openvz.org> writes:

> Eric W. Biederman wrote:
>> Pavel Emelyanov <xemul@openvz.org> writes:
>> 
>>>> +	}
>>>>  
>>>> -		tbp = peer_tb;
>>>> -	} else
>>>> -		tbp = tb;
>>> The intention of this part was to get the same parameters for
>>> peer as for the first device if no "peer" argument was specified
>>> for ip utility. Does it still work?
>> 
>> I know it is problematic because we try to assign the same name
>> to both network devices, if we assign a name to the primary
>> network device.  That can't work.
>
> This can - as you can see I reallocate the name lower.

Hmm. I just see:
	if (tbp[IFLA_IFNAME])
		nla_strlcpy(ifname, tbp[IFLA_IFNAME], IFNAMSIZ);

Then lower I see:
	if (tb[IFLA_IFNAME])
		nla_strlcpy(dev->name, tb[IFLA_IFNAME], IFNAMSIZ);

If (tb == tbp) then dev->name == ifname
Unless I'm completely misreading that code.

>> Beyond that I had some really weird crashes while testing this
>> piece of code, especially when I did not specify a peer parameter.
>
> Can you please give me the exact command that caused an oops.
> I try simple ip link add type veth and everything is just fine.

It might have been 64bit specific. 

What I have in my history is:
./ip/ip link add veth23 type veth

I forget exactly how it failed but as I recall it wasn't as
nice as an oops.  My memory may be a bit foggy though.

If I haven't provided a bit enough clue I guess I can go back
and remove the patch and try to reproduce the failure again.

>> So it was just easier to avoid the problem with this patch then
>> to completely root cause it.
>
> Let me handle this problem. AFAIR this was one of wishes from 
> Patrick that we make two equal devices in case peer is not given, 
> not just the default peer.

Ok.  I have if we can track down the weird cases I have no problem
if we handle this.  I think it still might be simpler if just
copy tb onto peer_tb instead of using tbp.

Eric
