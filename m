From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v4 3/3] net/xen-netback: Don't mix hexa and decimal with
 0x in the printf format
Date: Tue, 16 Jun 2015 23:07:57 +0300
Message-ID: <5580821D.4080408@cogentembedded.com>
References: <1434481848-26387-1-git-send-email-julien.grall@citrix.com> <1434481848-26387-4-git-send-email-julien.grall@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>, netdev@vger.kernel.org
To: Julien Grall <julien.grall@citrix.com>,
	xen-devel@lists.xenproject.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f48.google.com ([209.85.215.48]:34241 "EHLO
	mail-la0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753130AbbFPUIC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jun 2015 16:08:02 -0400
Received: by labbc20 with SMTP id bc20so18904266lab.1
        for <netdev@vger.kernel.org>; Tue, 16 Jun 2015 13:08:00 -0700 (PDT)
In-Reply-To: <1434481848-26387-4-git-send-email-julien.grall@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 06/16/2015 10:10 PM, Julien Grall wrote:

> Append 0x to all %x in order to avoid while reading when there is other
> decimal value in the log.

> Also replace some of the hexadecimal print to decimal to uniformize the
> format with netfront.

> Signed-off-by: Julien Grall <julien.grall@citrix.com>
> Cc: Wei Liu <wei.liu2@citrix.com>
> Cc: Ian Campbell <ian.campbell@citrix.com>
> Cc: netdev@vger.kernel.org

> ---
>      Changes in v4:
>          - Patch added
> ---
>   drivers/net/xen-netback/netback.c | 14 +++++++-------
>   1 file changed, 7 insertions(+), 7 deletions(-)

> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> index ba3ae30..11bd9d8 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
[...]
> @@ -874,7 +874,7 @@ static inline void xenvif_grant_handle_set(struct xenvif_queue *queue,
>   	if (unlikely(queue->grant_tx_handle[pending_idx] !=
>   		     NETBACK_INVALID_HANDLE)) {
>   		netdev_err(queue->vif->dev,
> -			   "Trying to overwrite active handle! pending_idx: %x\n",
> +			   "Trying to overwrite active handle! pending_idx: 0x%x\n",

    Using "%#x" is shorter ind does the same.

>   			   pending_idx);
>   		BUG();
>   	}
> @@ -887,7 +887,7 @@ static inline void xenvif_grant_handle_reset(struct xenvif_queue *queue,
>   	if (unlikely(queue->grant_tx_handle[pending_idx] ==
>   		     NETBACK_INVALID_HANDLE)) {
>   		netdev_err(queue->vif->dev,
> -			   "Trying to unmap invalid handle! pending_idx: %x\n",
> +			   "Trying to unmap invalid handle! pending_idx: 0x%x\n",

    Same here.

[...]
> @@ -1731,7 +1731,7 @@ void xenvif_idx_unmap(struct xenvif_queue *queue, u16 pending_idx)
>   				&queue->mmap_pages[pending_idx], 1);
>   	if (ret) {
>   		netdev_err(queue->vif->dev,
> -			   "Unmap fail: ret: %d pending_idx: %d host_addr: %llx handle: %x status: %d\n",
> +			   "Unmap fail: ret: %d pending_idx: %d host_addr: %llx handle: 0x%x status: %d\n",

    And here.

[...]

WBR, Sergei
