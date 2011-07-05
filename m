From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH 1/2] Update description of net.sctp.sctp_rmem and
 net.sctp.sctp_wmem tunables
Date: Tue, 5 Jul 2011 07:34:46 -0400
Message-ID: <20110705113446.GA2959@hmsreliant.think-freely.org>
References: <20110704083605.AF9C28156C57@regina.usersys.redhat.com>
 <20110704145454.GA10310@hmsreliant.think-freely.org>
 <19986.28723.546267.454485@regina.usersys.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: Max Matveev <makc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:34002 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932176Ab1GELe6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 07:34:58 -0400
Content-Disposition: inline
In-Reply-To: <19986.28723.546267.454485@regina.usersys.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 05, 2011 at 12:00:19PM +1000, Max Matveev wrote:
> On Mon, 4 Jul 2011 10:54:54 -0400, Neil Horman wrote:
> 
>  nhorman> On Mon, Jun 20, 2011 at 06:08:10PM +1000, Max Matveev wrote:
> 
>  >> sctp_rmem - vector of 3 INTEGERs: min, default, max
>  >> -	See tcp_rmem for a description.
>  >> +	Only the first value ("min") is used, "default" and "max" are
>  >> +	ignored and may be removed in the future versions.
>  >> +
> 
>  nhorman> Its accurate to say that only the first value is usd
>  nhorman> currently, but because of the way this sysctl is contructed
>  nhorman> (its used by the sysctl_rmem pointer in the sctp_prot
>  nhorman> struct, which expects an array of three integers in the
>  nhorman> commong __sk_mem_schedule function), we wont' be removing
>  nhorman> the other two values.
> 
> Technically it can be just a single integer - UDP does use it 
> that way but I'm not going to argue, v2 of the patch removed
> that bit.
> 
Yeah, but the only reason udp gets away with it is because the common code in
__sk_mem_schedule only happens to touch the first element in the array.  I
suppose we could just drop the array semantics in the common code and save the
sizeof(int) bytes per protocol, but then individual protocols may (or may not)
access other elements of the array.  Hmm, odd situation.  I'd just as soon leave
the sctp elements in place, they probably have use for ongoing work to fix up
sctp's buffer accounting.

Anywho, thanks!
Acked-by: Neil Horman <nhorman@tuxdriver.com>

> max
> 
