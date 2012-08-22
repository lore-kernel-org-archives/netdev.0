From: Chris Friesen <chris.friesen@genband.com>
Subject: Re: bonding: time limits too tight in bond_ab_arp_inspect
Date: Wed, 22 Aug 2012 12:58:24 -0600
Message-ID: <50352BD0.3060409@genband.com>
References: <20120822174534.GA20260@midget.suse.cz> <50351CC5.3030109@genband.com> <24655.1345660922@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Bohac <jbohac@suse.cz>, Andy Gospodarek <andy@greyhouse.net>,
	netdev@vger.kernel.org, Petr Tesarik <ptesarik@suse.cz>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og102.obsmtp.com ([64.18.2.157]:34917 "EHLO
	exprod7og102.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755342Ab2HVTAO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2012 15:00:14 -0400
In-Reply-To: <24655.1345660922@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/22/2012 12:42 PM, Jay Vosburgh wrote:
> Chris Friesen<chris.friesen@genband.com>  wrote:
>
>> On 08/22/2012 11:45 AM, Jiri Bohac wrote:
>>
>>> This code is run from bond_activebackup_arp_mon() about
>>> delta_in_ticks jiffies after the previous ARP probe has been
>>> sent. If the delayed work gets executed exactly in delta_in_ticks
>>> jiffies, there is a chance the slave will be brought up.  If the
>>> delayed work runs one jiffy later, the slave will stay down.
>
> 	Presumably the ARP reply is coming back in less than one jiffy,
> then, so the slave_last_rx() value is the same jiffy as when the
> _inspect was previously called?
>
>> <snip>
>>
>>> Should they perhaps all be increased by, say, delta_in_ticks/2, to make this
>>> less dependent on the current scheduling latencies?
>>
>> We have been using a patch that tracks the arpmon requested sleep time vs
>> the actual sleep time and adds any scheduling latency to the allowed
>> delta.  That way if we sleep too long due to scheduling latency it doesn't
>> affect the calculation.
>
> 	How much scheduling latency do you see?
>
> 	Is that really better than just permitting a bit more slack in
> the timing window?

We hit enough latency that it triggered arpmon to falsely mark multiple 
links as lost.  This triggered our system maintenance code to go into a 
"oh no we can't talk to the outside world" secenario, which does fairly 
intrusive things to try and bring connectivity back up.  Basically a bad 
thing to happen just because of a random scheduler latency spike.

I should note that we added this some time back and are still running 
older kernels so I have no idea what latency on modern kernels is like.

Chris
