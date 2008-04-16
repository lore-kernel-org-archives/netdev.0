From: "Stephens, Allan" <allan.stephens@windriver.com>
Subject: RE: [PATCH 1/7 net-2.6.26] [TIPC]: Remove inlining of reference table locking routines
Date: Wed, 16 Apr 2008 07:06:21 -0700
Message-ID: <29C1DC0826876849BDD9F1C67ABA294392B103@ala-mail09.corp.ad.wrs.com>
References: <1208288637-15304-1-git-send-email-allan.stephens@windriver.com><1208288637-15304-2-git-send-email-allan.stephens@windriver.com> <20080415.190001.248179700.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:55977 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755966AbYDPOGi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Apr 2008 10:06:38 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20080415.190001.248179700.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David:

Thanks for your clarifications on style/conventions ... all good points.

Does your preference for use of the "!ptr" style also apply to
non-pointer variables?  (For example, do you also prefer to see "!count"
rather than "count == 0"?)  I'm asking because I've received conflicting
guidance in the past (not from you, of course), which gave me the
impression that the "ptr == NULL" form was the way the Linux kernel
gatekeepers wanted to see things done.

Regards,
Al

-----Original Message-----
From: David Miller [mailto:davem@davemloft.net] 
Sent: Tuesday, April 15, 2008 10:00 PM
To: Stephens, Allan
Cc: netdev@vger.kernel.org
Subject: Re: [PATCH 1/7 net-2.6.26] [TIPC]: Remove inlining of reference
table locking routines

From: Allan Stephens <allan.stephens@windriver.com>
Date: Tue, 15 Apr 2008 15:43:51 -0400

> @@ -104,7 +135,7 @@ int tipc_ref_table_init(u32 requested_size, u32 
> start)
>  
>  void tipc_ref_table_stop(void)
>  {
> -	if (!tipc_ref_table.entries)
> +	if (unlikely(tipc_ref_table.entries == NULL))
>  		return;

Please don't mix gratuitous coding style changes with functional
changes.  It makes auditing and review harder.

And in this case I prefer the more concise "!ptr".

It also could be argued that this isn't a fast path and thus the
likely/unlikely tags are not only unnecessary, but also likely to result
in code bloat for no real gain.
