From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [IPoIB] Identify multicast packets and fix IGMP breakage V3
Date: Thu, 26 Aug 2010 17:07:16 -0700 (PDT)
Message-ID: <20100826.170716.68143372.davem@davemloft.net>
References: <alpine.DEB.2.00.1008261825490.26351@router.home>
	<20100826234342.GA24333@obsidianresearch.com>
	<alpine.DEB.2.00.1008261856090.29657@router.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org, rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ogerlitz-smomgflXvOZWk0Htik3J/w@public.gmane.org,
	yosefe-smomgflXvOZWk0Htik3J/w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <alpine.DEB.2.00.1008261856090.29657-sBS69tsa9Uj/9pzu0YdTqQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>
Date: Thu, 26 Aug 2010 18:57:09 -0500 (CDT)

> On Thu, 26 Aug 2010, Jason Gunthorpe wrote:
> 
>> I think doing the memcmp only in the multicast path should be
>> reasonable overhead wise.
> 
> Thats is not always possible. Here the multicast path is the
> default path that is taken 99% of the time.

The highest cost is bringing in that packet header's cache line, which
you've already done by reading the byte and checking for 0xff.

I doubt the memcmp() can possibly matter.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
