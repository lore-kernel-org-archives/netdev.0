From: annie li <annie.li@oracle.com>
Subject: Re: [Xen-devel] [PATCH net-next v4] xen-netfront: clean up code in
 xennet_release_rx_bufs
Date: Fri, 24 Jan 2014 19:05:26 +0800
Message-ID: <52E248F6.9080601@oracle.com>
References: <1390534095-5097-1-git-send-email-Annie.li@oracle.com> <52E24507.8060402@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wei.liu2@citrix.com,
	ian.campbell@citrix.com, xen-devel@lists.xen.org
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:41915 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752445AbaAXLFg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jan 2014 06:05:36 -0500
In-Reply-To: <52E24507.8060402@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 2014/1/24 18:48, David Vrabel wrote:
> On 24/01/14 03:28, Annie Li wrote:
>> From: Annie Li <annie.li@oracle.com>
>>
>> This patch removes grant transfer releasing code from netfront, and uses
>> gnttab_end_foreign_access to end grant access since
>> gnttab_end_foreign_access_ref may fail when the grant entry is
>> currently used for reading or writing.
>>
>> * clean up grant transfer code kept from old netfront(2.6.18) which grants
>> pages for access/map and transfer. But grant transfer is deprecated in current
>> netfront, so remove corresponding release code for transfer.
>>
>> * release grant access (through gnttab_end_foreign_access) and skb for tx/rx path,
>> use get_page to ensure page is released when grant access is completed successfully.
>>
>> Xen-blkfront/xen-tpmfront/xen-pcifront also have similar issue, but patches
>> for them will be created separately.
> ...
>> @@ -1439,8 +1403,11 @@ static int netfront_probe(struct xenbus_device *dev,
>>   static void xennet_end_access(int ref, void *page)
>>   {
>>   	/* This frees the page as a side-effect */
>> -	if (ref != GRANT_INVALID_REF)
>> +	if (ref != GRANT_INVALID_REF) {
>> +		get_page(virt_to_page(page));
>>   		gnttab_end_foreign_access(ref, 0, (unsigned long)page);
>> +		free_page((unsigned long)page);
>> +	}
>>   }

Oh, these code were kept from my debug, will remove it.

Thanks
Annie
> Please drop this hunk.
>
> Otherwise,
>
> Reviewed-by: David Vrabel <david.vrabel@citrix.com>
>
> David
>
> _______________________________________________
> Xen-devel mailing list
> Xen-devel@lists.xen.org
> http://lists.xen.org/xen-devel
