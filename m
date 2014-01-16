From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel][PATCH net-next v2] xen-netfront: clean up code in
 xennet_release_rx_bufs
Date: Thu, 16 Jan 2014 11:10:17 +0000
Message-ID: <52D7BE19.2010009@citrix.com>
References: <1389830228-2381-1-git-send-email-Annie.li@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>, <konrad.wilk@oracle.com>,
	<ian.campbell@citrix.com>, <wei.liu2@citrix.com>,
	<andrew.bennieston@citrix.com>
To: Annie Li <Annie.li@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:53509 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751632AbaAPLKT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jan 2014 06:10:19 -0500
In-Reply-To: <1389830228-2381-1-git-send-email-Annie.li@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15/01/14 23:57, Annie Li wrote:
> This patch implements two things:
> 
> * release grant reference and skb for rx path, this fixex resource leaking.
> * clean up grant transfer code kept from old netfront(2.6.18) which grants
> pages for access/map and transfer. But grant transfer is deprecated in current
> netfront, so remove corresponding release code for transfer.
> 
> gnttab_end_foreign_access_ref may fail when the grant entry is currently used
> for reading or writing. But this patch does not cover this and improvement for
> this failure may be implemented in a separate patch.

I don't think replacing a resource leak with a security bug is a good idea.

If you would prefer not to fix the gnttab_end_foreign_access() call, I
think you can fix this in netfront by taking a reference to the page
before calling gnttab_end_foreign_access().  This will ensure the page
isn't freed until the subsequent kfree_skb(), or the gref is released by
the foreign domain (whichever is later).

David
