From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCHv1 1/2] xen-netback: return correct ethtool stats
Date: Wed, 04 Mar 2015 15:50:48 +0300
Message-ID: <54F6FFA8.70505@cogentembedded.com>
References: <1425399971-27630-1-git-send-email-david.vrabel@citrix.com> <1425399971-27630-2-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xenproject.org,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: David Vrabel <david.vrabel@citrix.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f45.google.com ([209.85.215.45]:40352 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754347AbbCDMux (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2015 07:50:53 -0500
Received: by labgm9 with SMTP id gm9so4577578lab.7
        for <netdev@vger.kernel.org>; Wed, 04 Mar 2015 04:50:51 -0800 (PST)
In-Reply-To: <1425399971-27630-2-git-send-email-david.vrabel@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 3/3/2015 7:26 PM, David Vrabel wrote:

> Use correct pointer arithmetic to get the pointer to each stat.

> Signed-off-by: David Vrabel <david.vrabel@citrix.com>
> ---
>   drivers/net/xen-netback/interface.c |    3 +--
>   1 file changed, 1 insertion(+), 2 deletions(-)

> diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
> index f38227a..3aa8648 100644
> --- a/drivers/net/xen-netback/interface.c
> +++ b/drivers/net/xen-netback/interface.c
> @@ -340,12 +340,11 @@ static void xenvif_get_ethtool_stats(struct net_device *dev,
>   	unsigned int num_queues = vif->num_queues;
>   	int i;
>   	unsigned int queue_index;
> -	struct xenvif_stats *vif_stats;
>
>   	for (i = 0; i < ARRAY_SIZE(xenvif_stats); i++) {
>   		unsigned long accum = 0;
>   		for (queue_index = 0; queue_index < num_queues; ++queue_index) {
> -			vif_stats = &vif->queues[queue_index].stats;
> +			void *vif_stats = &vif->queues[queue_index].stats;

    Need empty line after declaration; checkpatch.pl should have complained here.

>   			accum += *(unsigned long *)(vif_stats + xenvif_stats[i].offset);
>   		}
>   		data[i] = accum;

WBR, Sergei
