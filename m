From: annie li <annie.li@oracle.com>
Subject: Re: [Xen-devel][PATCH net-next v2] xen-netfront: clean up code in
 xennet_release_rx_bufs
Date: Thu, 16 Jan 2014 21:42:19 +0800
Message-ID: <52D7E1BB.8000706@oracle.com>
References: <1389830228-2381-1-git-send-email-Annie.li@oracle.com> <52D7BE19.2010009@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xen.org, netdev@vger.kernel.org,
	davem@davemloft.net, konrad.wilk@oracle.com,
	ian.campbell@citrix.com, wei.liu2@citrix.com,
	andrew.bennieston@citrix.com
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:40675 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753068AbaAPNme (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 08:42:34 -0500
In-Reply-To: <52D7BE19.2010009@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 2014-1-16 19:10, David Vrabel wrote:
> On 15/01/14 23:57, Annie Li wrote:
>> This patch implements two things:
>>
>> * release grant reference and skb for rx path, this fixex resource leaking.
>> * clean up grant transfer code kept from old netfront(2.6.18) which grants
>> pages for access/map and transfer. But grant transfer is deprecated in current
>> netfront, so remove corresponding release code for transfer.
>>
>> gnttab_end_foreign_access_ref may fail when the grant entry is currently used
>> for reading or writing. But this patch does not cover this and improvement for
>> this failure may be implemented in a separate patch.
> I don't think replacing a resource leak with a security bug is a good idea.
>
> If you would prefer not to fix the gnttab_end_foreign_access() call, I
> think you can fix this in netfront by taking a reference to the page
> before calling gnttab_end_foreign_access().  This will ensure the page
> isn't freed until the subsequent kfree_skb(), or the gref is released by
> the foreign domain (whichever is later).

What I thought is to split the implementation into two patches, this 
patch fixes the rx path resource leak(just like what tx path does), then 
a separate patch fixes gnttab_end_foreign_access_ref failure issue for 
both tx/rx through taking reference to the page before 
gnttab_end_foreign_access.
If you'd like they are posted together, I will create new patch for the 
latter and then post them.:-)

Thanks
Annie
