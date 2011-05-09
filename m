From: Ben Greear <greearb@candelatech.com>
Subject: Re: Testing interface removal speedup patches from Eric Dumazet.
Date: Mon, 09 May 2011 12:42:39 -0700
Message-ID: <4DC843AF.6050607@candelatech.com>
References: <4DC83471.7030701@candelatech.com> <06627C760FB049F1A9321BC6@Ximines.local> <4DC83A57.40405@candelatech.com> <D8B72070C6338973B87C9EFA@Ximines.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Alex Bligh <alex@alex.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:58697 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754089Ab1EITmr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2011 15:42:47 -0400
In-Reply-To: <D8B72070C6338973B87C9EFA@Ximines.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/09/2011 12:12 PM, Alex Bligh wrote:
>
>
> --On 9 May 2011 12:02:47 -0700 Ben Greear <greearb@candelatech.com> wrote:
>
>
>>> So Eric's patches help in the interface create case, even though
>>> there is no synchronize_net, sychronize_sched() or rcu_barrier() there.
>>>
>>> I had assumed the slow create (which varies by number of pairs) was
>>> down to sysfs scalability only (see difference between 14ms and 110ms
>>> there).
>>
>> I'm not certain the create case is actually faster. Other runs on the
>> patched kernel showed create to be much closer to the un-patched kernel.
>>
>> The ratios to create/delete are more consistent it seems.
>>
>>> Out of interest, if you still happen to have the scripts around, how
>>> fast is veth creation if you just do 100 pairs?
>>
>> Created 500 veth in 17.874695 seconds (0.03574939 per interface).
>> Created 100 veth in 2.779905 seconds (0.02779905 per interface).
>
> Hmmm... well you are getting *far* better linearity than me. Creating
> 500 interfaces is 8 times slower *per interface* than doing 500.
>
> What occurs to me is that your box is faster than one of the ones I tested
> on, and you use CONFIG_HZ=100 but you get poorer results in absolute terms
> doing 100 (I see 14ms per interface). This with everything listenting to
> udev disabled? (so udevd dead, whatever executes your ifup/down scripts
> dead, unshare -n).

I use HZ of 1000, btw.

I killed udev, haldaemon..seemed to be just my stuff running.

I don't see any 'ifup' running with these things dead...

If you want to post your script, I can run it on my
machine...

Thanks,
Ben

>


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

