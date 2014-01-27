From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [PATCH net-next v5] xen-netfront: clean up code in
 xennet_release_rx_bufs
Date: Mon, 27 Jan 2014 10:22:58 +0000
Message-ID: <52E63382.6090503@citrix.com>
References: <1390731147-2424-1-git-send-email-Annie.li@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>,
	<konrad.wilk@oracle.com>, <ian.campbell@citrix.com>,
	<wei.liu2@citrix.com>
To: Annie Li <Annie.li@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:25857 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751741AbaA0KXA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jan 2014 05:23:00 -0500
In-Reply-To: <1390731147-2424-1-git-send-email-Annie.li@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26/01/14 10:12, Annie Li wrote:
> From: Annie Li <annie.li@oracle.com>
> 
> This patch removes grant transfer releasing code from netfront, and uses
> gnttab_end_foreign_access to end grant access since
> gnttab_end_foreign_access_ref may fail when the grant entry is
> currently used for reading or writing.
> 
> * clean up grant transfer code kept from old netfront(2.6.18) which grants
> pages for access/map and transfer. But grant transfer is deprecated in current
> netfront, so remove corresponding release code for transfer.
> 
> * release grant access (through gnttab_end_foreign_access) and skb for tx/rx path,
> use get_page to ensure page is released when grant access is completed successfully.
> 
> Xen-blkfront/xen-tpmfront/xen-pcifront also have similar issue, but patches
> for them will be created separately.
> 
> V5: Remove unecessary change in xennet_end_access.
> 
> V4: Revert put_page in gnttab_end_foreign_access, and keep netfront change in
> single patch.
> 
> V3: Changes as suggestion from David Vrabel, ensure pages are not freed untill
> grant acess is ended.
> 
> V2: Improve patch comments.
> 
> Signed-off-by: Annie Li <annie.li@oracle.com>

Reviewed-by: David Vrabel <david.vrabel@citrix.com>

I think this should be applied to net (and tagged as a stable candidate)
rather than net-next as this fixes are very big resource leak.

David
