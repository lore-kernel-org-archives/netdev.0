From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH  11/13] Core Resource Allocation
Date: Fri, 17 Nov 2006 08:54:06 -0800
Message-ID: <adaslgim2tt.fsf@cisco.com>
References: <20061116035826.22635.61230.stgit@dell3.ogc.int>
	<20061116035923.22635.5397.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: openib-general@openib.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:21654 "EHLO
	sj-iport-6.cisco.com") by vger.kernel.org with ESMTP
	id S932952AbWKQQyI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Nov 2006 11:54:08 -0500
To: Steve Wise <swise@opengridcomputing.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > +static u32 next_random(u32 rand)
 > +{
 > +	u32 y, ylast;
 > +
 > +	y = rand;	
 > +	ylast = y;
 > +	y = (y * 69069) & 0xffffffff;
 > +	y = (y & 0x80000000) + (ylast & 0x7fffffff);
 > +	if ((y & 1))
 > +		y = ylast ^ (y > 1) ^ (2567483615UL);
 > +	else
 > +		y = ylast ^ (y > 1);
 > +	y = y ^ (y >> 11);
 > +	y = y ^ ((y >> 7) & 2636928640UL);
 > +	y = y ^ ((y >> 15) & 4022730752UL);
 > +	y = y ^ (y << 18);
 > +	return y;
 > +}

How about just using the kernel's random32()?

I haven't read the code really so I don't understand what's being
randomized here, but random32() should be more than good enough for a
typical randomized algorithm().

 - R.
