From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [[Xen-devel] [PATCH net-next v3] xen-netfront: clean up code
 in xennet_release_rx_bufs
Date: Thu, 23 Jan 2014 10:55:36 +0000
Message-ID: <52E0F528.7060302@citrix.com>
References: <1390441011-3816-1-git-send-email-Annie.li@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>,
	<konrad.wilk@oracle.com>, <ian.campbell@citrix.com>,
	<wei.liu2@citrix.com>
To: Annie Li <Annie.li@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:40030 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751648AbaAWKz5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Jan 2014 05:55:57 -0500
In-Reply-To: <1390441011-3816-1-git-send-email-Annie.li@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 23/01/14 01:36, Annie Li wrote:
> From: Annie Li <annie.li@oracle.com>
> 
> This patch removes grant transfer code from netfront, and improves ending
> grant acess mechanism since gnttab_end_foreign_access_ref may fail when
> the grant entry is currently used for reading or writing.
> 
> * release grant reference and skb for tx/rx path, use get_page/put_page to
> ensure page is released when grant access is completed successfully.
> * change corresponding code in xen-blkfront/xen-tpmfront/xen-pcifront because
> of code change for put_page in gnttab_end_foreign_access.
> * clean up grant transfer code kept from old netfront(2.6.18) which grants
> pages for access/map and transfer. But grant transfer is deprecated in current
> netfront, so remove corresponding release code for transfer.
> 
> V3: Changes as suggestion from David Vrabel, ensure pages are not freed untill
> grant acess is ended.
> 
> V2: improve patch comments.
> Signed-off-by: Annie Li <annie.li@oracle.com>
> ---
>  drivers/block/xen-blkfront.c    |   25 ++++++++---
>  drivers/char/tpm/xen-tpmfront.c |    7 +++-
>  drivers/net/xen-netfront.c      |   93 ++++++++++++--------------------------
>  drivers/pci/xen-pcifront.c      |    7 +++-
>  drivers/xen/grant-table.c       |    4 +-
>  5 files changed, 63 insertions(+), 73 deletions(-)

I don't understand why you've made all these unnecessary changes to the
other frontends and grant-table.c.

The xen-netfront.c changes are fine on their own.

David
