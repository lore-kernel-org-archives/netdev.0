From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Understanding lock contention in __udp4_lib_mcast_deliver
Date: Thu, 27 Jun 2013 15:03:15 -0700
Message-ID: <51CCB6A3.9080806@hp.com>
References: <20130627192218.GA5936@sbohrermbp13-local.rgmadvisors.com> <51CC996F.3020507@hp.com> <20130627202008.GB5936@sbohrermbp13-local.rgmadvisors.com> <51CCA4C2.7050301@hp.com> <20130627215411.GC5936@sbohrermbp13-local.rgmadvisors.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Shawn Bohrer <sbohrer@rgmadvisors.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:14663 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753727Ab3F0WDR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jun 2013 18:03:17 -0400
In-Reply-To: <20130627215411.GC5936@sbohrermbp13-local.rgmadvisors.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/27/2013 02:54 PM, Shawn Bohrer wrote:
> On Thu, Jun 27, 2013 at 01:46:58PM -0700, Rick Jones wrote:
>> How do you know that time is actually contention and not simply
>> acquire and release overhead?
>
> Excellent point, and that could be the problem with my thinking.  I
> just now tried (unsuccessfully) to use lockstat to see if there was
> any contention reported.  I read Documentation/lockstat.txt and
> followed the instructions but the lock in question did not appear to
> be in the output.  I think I'm going to have to go with the assumption
> that this is just acquire and release overhead.

I think there is a way to get perf to "annotate" (iirc that is the term 
it uses) the report to show hits at the instruction level.  Ostensibly 
one could then look and see how many of the hits were for the 
acquire/release part of the routine, and how much was for the actual 
contention.

Another way to go, perhaps, would be to break-out the "contention" 
portion into a separate routine.  Then the question of contention versus 
acquire/release would be clearly answered in a profile without needing 
to take the annotation path.  Long ago and far away in IA64 land that 
was done.  An example can be seen in:

ftp://ftp.netperf.org/iptable_scaling/full_iptables/32_core_net_next_full_iptables_cycles.txt

where you will see "ia64_spinlock_contention" rather high in the 
profile. (That was taken with HP's "caliper" tool, when perfmon was the 
mechanism in use for accessing performance counters)

rick jones
