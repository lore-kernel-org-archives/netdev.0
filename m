From: Ben Greear <greearb@candelatech.com>
Subject: Re: Testing interface removal speedup patches from Eric Dumazet.
Date: Mon, 09 May 2011 12:02:47 -0700
Message-ID: <4DC83A57.40405@candelatech.com>
References: <4DC83471.7030701@candelatech.com> <06627C760FB049F1A9321BC6@Ximines.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Alex Bligh <alex@alex.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:35906 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751261Ab1EITC5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2011 15:02:57 -0400
In-Reply-To: <06627C760FB049F1A9321BC6@Ximines.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/09/2011 11:56 AM, Alex Bligh wrote:
>
>
> --On 9 May 2011 11:37:37 -0700 Ben Greear <greearb@candelatech.com> wrote:
>
> With:
>> Created 500 veth in 17.874695 seconds (0.03574939 per interface).
>> Deleted 500 veth in 17.023607 seconds. (0.034047214 per interface)
> Without:
>> Created 500 veth in 22.507598 seconds (0.045015196 per interface).
>> Deleted 500 veth in 34.998733 seconds. (0.069997466 per interface)
>
> Interesting. On my tests (albeit with CONFIG_HZ=100) I got:
>
> 100 pairs 500 pairs
> Interface creation 14ms 110ms
> Interface deletion 160ms 148ms
>
> So Eric's patches help in the interface create case, even though
> there is no synchronize_net, sychronize_sched() or rcu_barrier() there.
>
> I had assumed the slow create (which varies by number of pairs) was
> down to sysfs scalability only (see difference between 14ms and 110ms
> there).

I'm not certain the create case is actually faster.  Other runs on the
patched kernel showed create to be much closer to the un-patched kernel.

The ratios to create/delete are more consistent it seems.

> Out of interest, if you still happen to have the scripts around, how
> fast is veth creation if you just do 100 pairs?

Created 100 veth in 2.779905 seconds (0.02779905 per interface).
Added IP addresses in 2.280084 seconds (0.02280084 per addr).
Deleted 100 veth in 3.988818 seconds. (0.03988818 per interface)

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

