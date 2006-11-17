From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: [PATCH  11/13] Core Resource Allocation
Date: Fri, 17 Nov 2006 11:25:11 -0600
Message-ID: <1163784311.8457.44.camel@stevo-desktop>
References: <20061116035826.22635.61230.stgit@dell3.ogc.int>
	 <20061116035923.22635.5397.stgit@dell3.ogc.int> <adaslgim2tt.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: openib-general@openib.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-153-218-104.sw.biz.rr.com ([24.153.218.104]:34749 "EHLO
	smtp.opengridcomputing.com") by vger.kernel.org with ESMTP
	id S933741AbWKQRZM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Nov 2006 12:25:12 -0500
To: Roland Dreier <rdreier@cisco.com>
In-Reply-To: <adaslgim2tt.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-11-17 at 08:54 -0800, Roland Dreier wrote:
>  > +static u32 next_random(u32 rand)
>  > +{
>  > +	u32 y, ylast;
>  > +
>  > +	y = rand;	
>  > +	ylast = y;
>  > +	y = (y * 69069) & 0xffffffff;
>  > +	y = (y & 0x80000000) + (ylast & 0x7fffffff);
>  > +	if ((y & 1))
>  > +		y = ylast ^ (y > 1) ^ (2567483615UL);
>  > +	else
>  > +		y = ylast ^ (y > 1);
>  > +	y = y ^ (y >> 11);
>  > +	y = y ^ ((y >> 7) & 2636928640UL);
>  > +	y = y ^ ((y >> 15) & 4022730752UL);
>  > +	y = y ^ (y << 18);
>  > +	return y;
>  > +}
> 
> How about just using the kernel's random32()?
> 
> I haven't read the code really so I don't understand what's being
> randomized here, but random32() should be more than good enough for a
> typical randomized algorithm().
> 
>  - R.

I think we can use random32() or get_random_bytes().  I need to
re-review how this algorithm works.  Its randomizing the stag IDs so
they are not predictable.

Steve.



