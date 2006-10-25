From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: Re: [PATCH] hostap_plx: fix CIS verification
Date: Tue, 24 Oct 2006 19:31:19 -0700
Message-ID: <20061025023119.GB6121@jm.kir.nu>
References: <1161382815.5803.2.camel@dv> <20061021011943.GC6140@jm.kir.nu> <1161742344.29939.6.camel@dv>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, hostap@shmoo.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.genealogia.fi ([194.100.116.229]:60618 "EHLO
	mail2.genealogia.fi") by vger.kernel.org with ESMTP
	id S1422894AbWJYCcu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Oct 2006 22:32:50 -0400
To: Pavel Roskin <proski@gnu.org>
Content-Disposition: inline
In-Reply-To: <1161742344.29939.6.camel@dv>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 24, 2006 at 10:12:24PM -0400, Pavel Roskin wrote:

> Coverity has no means to interpret CIS.  However, it may understand
> kmalloc, which allocates CIS_MAX_LEN for the CIS copy.
> 
> The value of cis[pos + 1] has no bearing on the validity of the access
> to cis[pos + 5] from the point of view of a checking tool.

Indeed.

> pos is already checked in the beginning of the loop to be small enough,
> but the check is not strong enough.  The next tuple starts at (pos +
> cis[pos + 1] + 2), and we want that to be at most CIS_MAX_LEN.
> 
> That's something Coverity could have found.

Agreed and I went through the report at some point and I think I found
it to be valid..

> So, the right fix would be:
> -		if (pos + cis[pos + 1] >= CIS_MAX_LEN)
> +		if (pos + 2 + cis[pos + 1] > CIS_MAX_LEN)
>  			goto cis_error;

> I'm rewriting this with "<" because it's easier to read.  Next tuple at
> exactly CIS_MEX_LEN is fine - we just stop precessing at that point.
> 
> I'm going to combine this with my previous fix and resend.

Great, thanks!

-- 
Jouni Malinen                                            PGP id EFC895FA
