From: Alex Bligh <alex@alex.org.uk>
Subject: Re: Testing interface removal speedup patches from Eric Dumazet.
Date: Mon, 09 May 2011 20:12:39 +0100
Message-ID: <D8B72070C6338973B87C9EFA@Ximines.local>
References: <4DC83471.7030701@candelatech.com>
 <06627C760FB049F1A9321BC6@Ximines.local> <4DC83A57.40405@candelatech.com>
Reply-To: Alex Bligh <alex@alex.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Alex Bligh <alex@alex.org.uk>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.avalus.com ([89.16.176.221]:33310 "EHLO mail.avalus.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753900Ab1EITMl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 May 2011 15:12:41 -0400
In-Reply-To: <4DC83A57.40405@candelatech.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



--On 9 May 2011 12:02:47 -0700 Ben Greear <greearb@candelatech.com> wrote:


>> So Eric's patches help in the interface create case, even though
>> there is no synchronize_net, sychronize_sched() or rcu_barrier() there.
>>
>> I had assumed the slow create (which varies by number of pairs) was
>> down to sysfs scalability only (see difference between 14ms and 110ms
>> there).
>
> I'm not certain the create case is actually faster.  Other runs on the
> patched kernel showed create to be much closer to the un-patched kernel.
>
> The ratios to create/delete are more consistent it seems.
>
>> Out of interest, if you still happen to have the scripts around, how
>> fast is veth creation if you just do 100 pairs?
>
> Created 500 veth in 17.874695 seconds (0.03574939 per interface).
> Created 100 veth in 2.779905 seconds (0.02779905 per interface).

Hmmm... well you are getting *far* better linearity than me. Creating
500 interfaces is 8 times slower *per interface* than doing 500.

What occurs to me is that your box is faster than one of the ones I tested
on, and you use CONFIG_HZ=100 but you get poorer results in absolute terms
doing 100 (I see 14ms per interface). This with everything listenting to
udev disabled? (so udevd dead, whatever executes your ifup/down scripts
dead, unshare -n).

-- 
Alex Bligh
