From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: [PATCH] RDSRDMA: Fix cleanup of rds_iw_mr_pool
Date: Fri, 09 Sep 2011 14:01:53 -0500
Message-ID: <4E6A62A1.1010702@opengridcomputing.com>
References: <67e08fa0-c2e1-44f8-ab8b-45e4bfdc9264@default>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>,
	Netdev <netdev@vger.kernel.org>,
	Rds-Devel <rds-devel@oss.oracle.com>,
	Jonathan Lallinger <jonathan@ogc.us>
To: Davem <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:36015 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759762Ab1IITCS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2011 15:02:18 -0400
In-Reply-To: <67e08fa0-c2e1-44f8-ab8b-45e4bfdc9264@default>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/09/2011 09:37 AM, Venkat Venkatsubra wrote:
> On 09/08/2011 01:04 PM, Jonathan Lallinger wrote:
>> In the rds_iw_mr_pool struct the free_pinned field keeps track of memory pinned
>> by free MRs. While this field is incremented properly upon allocation, it is never
>> decremented upon unmapping. This would cause the rds_rdma module to crash the
>> kernel upon unloading, by triggering the BUG_ON in the rds_iw_destroy_mr_pool
>> function.
>>
>> This change keeps track of the MRs that become unpinned, so that free_pinned
>> can be decremented appropriately.
>>
>> Signed-off-by: Jonathan Lallinger<jonathan@ogc.us>
>> Signed-off-by: Steve Wise<swise@ogc.us>
> Signed-off-by: Venkat Venkatsubra<venkat.x.venkatsubra@oracle.com>
>
> Venkat
>

Hey Dave,

Is this sufficient for you to pull/merge the patch upstream?  Or should Venkat, the new RDS maintainer, do something 
else?  Like maybe coalesce patches into a git repos and ask you to pull them in?  I'm not sure what process you had with 
the old RDS maintainer.

There's another patch too from Jonathan Lallinger that fixes an RDS crash titled:

[PATCH] RDSRDMA: Fix to PAGE_MASK interpretation

Both have been signed off by Venkat and reviewed by me.


Thanks,

Steve.
