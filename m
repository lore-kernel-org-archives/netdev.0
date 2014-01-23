From: Annie <annie.li@oracle.com>
Subject: Re: [[Xen-devel] [PATCH net-next v3] xen-netfront: clean up code in xennet_release_rx_bufs
Date: Thu, 23 Jan 2014 21:38:04 +0800
Message-ID: <1317802A-6BB6-468B-9FA0-8A05CDDFEA8C@oracle.com>
References: <1390441011-3816-1-git-send-email-Annie.li@oracle.com> <52E0F528.7060302@citrix.com>
Mime-Version: 1.0 (1.0)
Content-Type: text/plain;
	charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	"ian.campbell@citrix.com" <ian.campbell@citrix.com>,
	"wei.liu2@citrix.com" <wei.liu2@citrix.com>
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:27731 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751592AbaAWNiX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jan 2014 08:38:23 -0500
In-Reply-To: <52E0F528.7060302@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>




On 01/23/2014 2:55 AM, David Vrabel <david.vrabel@citrix.com> wrote

> On 23/01/14 01:36, Annie Li wrote:
>> From: Annie Li <annie.li@oracle.com>
>> 
>> This patch removes grant transfer code from netfront, and improves ending
>> grant acess mechanism since gnttab_end_foreign_access_ref may fail when
>> the grant entry is currently used for reading or writing.
>> 
>> * release grant reference and skb for tx/rx path, use get_page/put_page to
>> ensure page is released when grant access is completed successfully.
>> * change corresponding code in xen-blkfront/xen-tpmfront/xen-pcifront because
>> of code change for put_page in gnttab_end_foreign_access.
>> * clean up grant transfer code kept from old netfront(2.6.18) which grants
>> pages for access/map and transfer. But grant transfer is deprecated in current
>> netfront, so remove corresponding release code for transfer.
>> 
>> V3: Changes as suggestion from David Vrabel, ensure pages are not freed untill
>> grant acess is ended.
>> 
>> V2: improve patch comments.
>> Signed-off-by: Annie Li <annie.li@oracle.com>
>> ---
>> drivers/block/xen-blkfront.c    |   25 ++++++++---
>> drivers/char/tpm/xen-tpmfront.c |    7 +++-
>> drivers/net/xen-netfront.c      |   93 ++++++++++++--------------------------
>> drivers/pci/xen-pcifront.c      |    7 +++-
>> drivers/xen/grant-table.c       |    4 +-
>> 5 files changed, 63 insertions(+), 73 deletions(-)
> 
> I don't understand why you've made all these unnecessary changes to the
> other frontends and grant-table.c.
> 
> The xen-netfront.c changes are fine on their own.

Changes in grant-table.c corresponds to get_page before gnttab_end_foreign_access, just keeping consistent in the function name. This change does not really change the mechanism, so I can revert it.

For the changes in other frontends, the reason is they also have similar issue - grant access probably is not ended successfully when the page is freed.

Thanks
Annie
> 
> David
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
