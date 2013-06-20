From: Vipul Pandya <vipul@chelsio.com>
Subject: Re: [PATCH V2 0/4] Add IPv6 support for iWARP
Date: Thu, 20 Jun 2013 19:07:17 +0530
Message-ID: <51C3058D.205@chelsio.com>
References: <1371037302-3586-1-git-send-email-vipul@chelsio.com> <20130619.180120.1989500368231967461.davem@davemloft.net> <51C266A1.2050003@opengridcomputing.com> <20130619.210805.224358826374432656.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: SWise OGC <swise@opengridcomputing.com>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"roland@purestorage.com" <roland@purestorage.com>,
	Divy Le Ray <divy@chelsio.com>,
	Dimitrios Michailidis <dm@chelsio.com>,
	"roland@kernel.org" <roland@kernel.org>,
	"sean.hefty@intel.com" <sean.hefty@intel.com>,
	"hal.rosenstock@gmail.com" <hal.rosenstock@gmail.com>,
	Tom Tucker <tom@opengridcomputing.com>,
	"faisal.latif@intel.com" <faisal.latif@intel.com>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"sasha.levin@oracle.com" <sasha.levin@oracle.com>,
	Nirranjan Kirubaharan <nirranjan@chelsio.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:19845 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757531Ab3FTNhh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jun 2013 09:37:37 -0400
In-Reply-To: <20130619.210805.224358826374432656.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 20-06-2013 09:38, David Miller wrote:
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
>>
>> Reviewed-by: Steve Wise <swise@opengridcomputing.com>
> 
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
>  	struct tid_info *t = dev->rdev.lldi.tids;
>  	int status = GET_AOPEN_STATUS(ntohl(rpl->atid_status));
> +	struct sockaddr_in *la = (struct sockaddr_in *)&ep->com.local_addr;
> +	struct sockaddr_in *ra = (struct sockaddr_in *)&ep->com.remote_addr;
> +	struct sockaddr_in6 *la6 = (struct sockaddr_in6 *)&ep->com.local_addr;
> +	struct sockaddr_in6 *ra6 = (struct sockaddr_in6 *)&ep->com.remote_addr;
> +
> +
>  
>  	ep = lookup_atid(t, atid);
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

I am really very sorry for this. Somehow my compiler is not giving me
any warnings for this. My compiler is gcc 4.4.6 20120305 (Red Hat
4.4.6-4). Previously also once it has happened that my compiler did not
give any warning but your build environment caught. Is there any special
gcc option I have to pass with make command for this? I am following the
checklist mentioned in Documentation/SubmitChecklist file.

We always make sure all our drivers are building cleanly before
submitting the drivers. We also have unit tested this code. However the
problematic code gets executed only in error path hence could not catch
during unit testing.

I will resubmitt the series with the changes. Your review comments are
very valuable for us.
