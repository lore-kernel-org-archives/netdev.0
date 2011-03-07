From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [rds-devel] [PATCH] rds: prevent BUG_ON triggering on congestion
 map updates
Date: Mon, 7 Mar 2011 15:56:30 -0500
Message-ID: <20110307205630.GB31788@hmsreliant.think-freely.org>
References: <1299083302-5168-1-git-send-email-nhorman@tuxdriver.com>
 <20110307.122753.59686845.davem@davemloft.net>
 <1299530363-sup-8922@think>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	rds-devel <rds-devel@oss.oracle.com>,
	Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>
To: Chris Mason <chris.mason@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:52768 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753494Ab1CGU4i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2011 15:56:38 -0500
Content-Disposition: inline
In-Reply-To: <1299530363-sup-8922@think>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 07, 2011 at 03:41:04PM -0500, Chris Mason wrote:
> Excerpts from David Miller's message of 2011-03-07 15:27:53 -0500:
> > From: Neil Horman <nhorman@tuxdriver.com>
> > Date: Wed,  2 Mar 2011 11:28:22 -0500
> > 
> > > Recently had this bug halt reported to me:
> > 
> > Well, does anyone on the RDS team care about this bug fix at all?
> > 
> > Stuff like this should not sit for nearly a week without any reply
> > whatsoever.
> > 
> 
> The patch looks good to me, but I'm surprised we haven't seen it here.
> Venkat please take a look (link to the patch below)  Has it only been seen on ppc?
> 
Yes, its only been observed on ppc64.  Its does seem like it should be
observable on other arches.  I presumed it had something to do with ppc64
alignment and how it filled in the sg array, that led to a leftover bit of space
in the scattergather array.  Honestly though I wasnt too worried about ferreting
out the source, since it seemed apparent to me that buffers with
RDS_FLAG_CONG_BITMAP set were just causing rds_[loop|ib]_xmit to return a dummy
positive value (I say dummy because theres no actual data transmitted).  So I
figured if the value is just there to satisfy the return code, it might as well
also satisfy what is otherwise a valid BUG_ON check too.

Best
Neil

> http://permalink.gmane.org/gmane.linux.network/187933
> 
> -chris
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
