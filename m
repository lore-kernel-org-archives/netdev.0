From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: RFC [PATCH net-2.6 1/6] net: Scheduling softirqs between CPUSs
Date: Wed, 12 Mar 2008 15:10:52 +0000
Message-ID: <20080312151051.GI26963@solarflare.com>
References: <20080305205116.5989A412541@localhost> <20080305.132112.01598419.davem@davemloft.net> <47D19147.9070609@qualcomm.com> <36D9DB17C6DE9E40B059440DB8D95F52049D5CE5@orsmsx418.amr.corp.intel.com> <65634d660803110920g5103dc60ya055a10f999b4e25@mail.gmail.com> <20080311165253.GG26963@solarflare.com> <65634d660803111648l15c4d653t52b4fc9e8dfa531d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	Max Krasnyanskiy <maxk@qualcomm.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Steven Rostedt <rostedt@goodmis.org>,
	Ingo Molnar <mingo@elte.hu>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pythagoras.zen.co.uk ([212.23.3.140]:59257 "EHLO
	pythagoras.zen.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751752AbYCLPLG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Mar 2008 11:11:06 -0400
Content-Disposition: inline
In-Reply-To: <65634d660803111648l15c4d653t52b4fc9e8dfa531d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tom Herbert wrote:
> >  Recent versions of Windows that are aware of RSS will instruct network
> >  drivers to update their RSS indirection tables so that received
> >  packets are handled on the same CPU as the thread likely to use the
> >  received data.  This requires that the network stack knows the hash
> >  function, so Microsoft specified a "Toeplitz hash" for IPv4 and IPv6.
> >  You can expect that most hardware RSS implementations will use this
> >  function and not a simple XOR.
> >
> 
> Thanks.  I am planning to do the Toeplitz hash in the softRSS.  Also,
> I was planning to add support for devices that provide the Toeplitz
> hash but don't do full RSS.
> 
> One nice feature about Microsoft RSS seems to be the ability for the
> stack to dynamically re-balance networking load of a device using
> an indirection table that is set up in the device.  I was wondering if
> this is supported in Linux stack or if anyone is working on that?

It's not supported, but it's on David Miller's to-do list[1].

By the way, Microsoft suddenly decided that RSS is too problematic to
enable by default[2] because software and hardware can disagree about
hash values in the presence of some local NAT implementations.
Hopefully we can avoid that particular pitfall in Linux.

Ben.

1. http://vger.kernel.org/~davem/net_todo.html
2. http://support.microsoft.com/kb/948496

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
