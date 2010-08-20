From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: ip_tables.h can't be used in C++ programs.
Date: Sat, 21 Aug 2010 00:17:09 +0100
Message-ID: <1282346230.3454.193.camel@localhost>
References: <4C6ECF67.3040508@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:50615 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750861Ab0HTXRO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Aug 2010 19:17:14 -0400
In-Reply-To: <4C6ECF67.3040508@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-08-20 at 11:54 -0700, Ben Greear wrote:
> This method returns void* but is defined to return
> a pointer to struct ipt_entry_target.
> 
> This will not compile under g++ (or, I'm unable to figure out
> how to make it work w/out editing the header file).
> 
> Any reason this shouldn't be changed to:
> 
>   return (struct ipt_entry_target*)e + e->target_offset;

Because that multiplies the offset by sizeof(struct ipt_entry_target)!

> /* Helper functions */
> static __inline__ struct ipt_entry_target *
> ipt_get_target(struct ipt_entry *e)
> {
>          return (void *)e + e->target_offset;
> }

For extra unportability, this is relying on the gcc extension for void
pointer arithmetic.  Try something like:

	return (struct ipt_entry_target *)((char *)e + e->target_offset);

Ben.

> IPv6 has similar issue....
> 
> Thanks,
> Ben
> 

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

