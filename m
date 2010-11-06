From: Mikael Abrahamsson <swmike@swm.pp.se>
Subject: Re: radvd and auto-ipv6 address regression from 2.6.31 to 2.6.34+
Date: Sat, 6 Nov 2010 07:17:41 +0100 (CET)
Message-ID: <alpine.DEB.1.10.1011060713290.2639@uplift.swm.pp.se>
References: <4CD47622.5040507@candelatech.com> <4CD48FB4.2050903@candelatech.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Cc: NetDev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from swm.pp.se ([212.247.200.143]:40387 "EHLO uplift.swm.pp.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753142Ab0KFGXq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 Nov 2010 02:23:46 -0400
In-Reply-To: <4CD48FB4.2050903@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 5 Nov 2010, Ben Greear wrote:

>> On hacked 2.6.34 and 2.6.36 kernels, however, the veth0 gains a new 
>> address that appears to be generated similar to other IPs associated 
>> with auto-creation via radvd.
>> 
>> I have not yet tested intervening kernels or physical interfaces between
>> two machines.
>> 
>> So, the question is: Is the new behaviour on purpose, or is it a
>> regression bug?
>
> Actually, this doesn't seem to work for 2.6.31 either, so I guess it
> isn't a regression.
>
> Is it expected behaviour, however?

I would not be surprised if the IPv6 stack on Linux would gain IPv6 
addresses using SLAAC from any interface if it sees RAs on it, regardless 
if these are locally generated or not.

I guess any Linux device running radvd should turn off autoconf on those 
interface that radvd is acting on?

net.ipv6.conf.veth0.accept_ra=0 should do the trick?

-- 
Mikael Abrahamsson    email: swmike@swm.pp.se
