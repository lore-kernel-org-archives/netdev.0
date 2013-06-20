From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH V2 0/4] Add IPv6 support for iWARP
Date: Wed, 19 Jun 2013 21:08:05 -0700 (PDT)
Message-ID: <20130619.210805.224358826374432656.davem@davemloft.net>
References: <1371037302-3586-1-git-send-email-vipul@chelsio.com>
	<20130619.180120.1989500368231967461.davem@davemloft.net>
	<51C266A1.2050003@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org, divy-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, tom-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org,
	faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	sasha.levin-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, nirranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
To: swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <51C266A1.2050003-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
Date: Wed, 19 Jun 2013 21:19:13 -0500

> On 6/19/2013 8:01 PM, David Miller wrote:
>> From: Vipul Pandya <vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
>> Date: Wed, 12 Jun 2013 17:11:38 +0530
>>
>>> We have included all the maintainers of respective drivers. Kindly
>>> review the change and let us know in case of any review comments.
>> I have not seen anyone review v2 of this patch series.
>>
> 
> Reviewed-by: Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>

You wrote the first patch, and I bet you didn't even read the code in
the cxgb4 driver.  So your review is sort of pointless... UNLESS you
spotted the obvious bugs in these changes, that would have been
interesting.

Because NOBODY, and I mean NOBODY, even looked at the build of the
cxgb4 changes.

Tell me what this does:

 	struct tid_info *t = dev->rdev.lldi.tids;
 	int status = GET_AOPEN_STATUS(ntohl(rpl->atid_status));
+	struct sockaddr_in *la = (struct sockaddr_in *)&ep->com.local_addr;
+	struct sockaddr_in *ra = (struct sockaddr_in *)&ep->com.remote_addr;
+	struct sockaddr_in6 *la6 = (struct sockaddr_in6 *)&ep->com.local_addr;
+	struct sockaddr_in6 *ra6 = (struct sockaddr_in6 *)&ep->com.remote_addr;
+
+
 
 	ep = lookup_atid(t, atid);

Dereferencing 'ep' before initializing it.

The compiler complains loudly about this, therefore nobody even looked at
the build logs from these changes before submitting them to me.

That translates to "don't care", and if the people submitting this
code don't care why should I?

Sorry, not impressed.  I'm seriously going to take my time reviewing
any future submissions of these changes, because it's obvious that
even the people writing and submitting this code DO NOT CARE.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
