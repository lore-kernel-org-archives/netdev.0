From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Understanding lock contention in __udp4_lib_mcast_deliver
Date: Thu, 27 Jun 2013 12:58:39 -0700
Message-ID: <51CC996F.3020507@hp.com>
References: <20130627192218.GA5936@sbohrermbp13-local.rgmadvisors.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Shawn Bohrer <sbohrer@rgmadvisors.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0008.atlanta.hp.com ([15.192.0.45]:25248 "EHLO
	g5t0008.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754565Ab3F0T6l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jun 2013 15:58:41 -0400
In-Reply-To: <20130627192218.GA5936@sbohrermbp13-local.rgmadvisors.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/27/2013 12:22 PM, Shawn Bohrer wrote:
> I'm looking for opportunities to improve the multicast receive
> performance for our application, and I thought I'd spend some time
> trying to understand what I thought might be a small/simple
> improvement.  Profiling with perf I see that there is spin_lock
> contention in __udp4_lib_mcast_deliver:
>
> 0.68%  swapper  [kernel.kallsyms]               [k] _raw_spin_lock
>         |
>         --- _raw_spin_lock
>            |
>            |--24.13%-- perf_adjust_freq_unthr_context.part.21
>            |
>            |--22.40%-- scheduler_tick
>            |
>            |--14.96%-- __udp4_lib_mcast_deliver

Are there other processes showing _raw_spin_lock time?  It may be more 
clear to add a --sort symbol,dso or some such to your perf report 
command.  Because what you show there suggests less than 1% of the 
active cycles are in _raw_spin_lock.

rick jones
