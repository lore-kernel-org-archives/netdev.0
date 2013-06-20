From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: [PATCH V2 0/4] Add IPv6 support for iWARP
Date: Thu, 20 Jun 2013 08:33:05 -0500
Message-ID: <51C30491.1050507@opengridcomputing.com>
References: <1371037302-3586-1-git-send-email-vipul@chelsio.com> <20130619.180120.1989500368231967461.davem@davemloft.net> <51C266A1.2050003@opengridcomputing.com> <20130619.210805.224358826374432656.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: vipul@chelsio.com, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org, roland@purestorage.com, divy@chelsio.com,
	dm@chelsio.com, roland@kernel.org, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, tom@opengridcomputing.com,
	faisal.latif@intel.com, akpm@linux-foundation.org,
	sasha.levin@oracle.com, nirranjan@chelsio.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([72.48.136.20]:52110 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757531Ab3FTNdC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jun 2013 09:33:02 -0400
In-Reply-To: <20130619.210805.224358826374432656.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/19/2013 11:08 PM, David Miller wrote:
> From: Steve Wise <swise@opengridcomputing.com>
> Date: Wed, 19 Jun 2013 21:19:13 -0500
>
>> On 6/19/2013 8:01 PM, David Miller wrote:
>>> From: Vipul Pandya <vipul@chelsio.com>
>>> Date: Wed, 12 Jun 2013 17:11:38 +0530
>>>
>>>> We have included all the maintainers of respective drivers. Kindly
>>>> review the change and let us know in case of any review comments.
>>> I have not seen anyone review v2 of this patch series.
>>>
>> Reviewed-by: Steve Wise <swise@opengridcomputing.com>
> You wrote the first patch, and I bet you didn't even read the code in
> the cxgb4 driver.  So your review is sort of pointless... UNLESS you
> spotted the obvious bugs in these changes, that would have been
> interesting.
>
> Because NOBODY, and I mean NOBODY, even looked at the build of the
> cxgb4 changes.
>
> Tell me what this does:
>
>   	struct tid_info *t = dev->rdev.lldi.tids;
>   	int status = GET_AOPEN_STATUS(ntohl(rpl->atid_status));
> +	struct sockaddr_in *la = (struct sockaddr_in *)&ep->com.local_addr;
> +	struct sockaddr_in *ra = (struct sockaddr_in *)&ep->com.remote_addr;
> +	struct sockaddr_in6 *la6 = (struct sockaddr_in6 *)&ep->com.local_addr;
> +	struct sockaddr_in6 *ra6 = (struct sockaddr_in6 *)&ep->com.remote_addr;
> +
> +
>   
>   	ep = lookup_atid(t, atid);
>
> Dereferencing 'ep' before initializing it.
>
> The compiler complains loudly about this, therefore nobody even looked at
> the build logs from these changes before submitting them to me.
>
> That translates to "don't care", and if the people submitting this
> code don't care why should I?
>
> Sorry, not impressed.  I'm seriously going to take my time reviewing
> any future submissions of these changes, because it's obvious that
> even the people writing and submitting this code DO NOT CARE.
>

We do care.  We screwed up.
