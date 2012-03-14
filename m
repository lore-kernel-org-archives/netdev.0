From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [net 2/2] net: fix a bug of dropping FCoE frames when disabling
 tx ip checksum
Date: Wed, 14 Mar 2012 08:25:29 -0700
Message-ID: <20120314082529.584a669f@nehalam.linuxnetplumber.net>
References: <1331708518-28120-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1331708518-28120-2-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Yi Zou <yi.zou@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:49002 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753563Ab2CNPZc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Mar 2012 11:25:32 -0400
In-Reply-To: <1331708518-28120-2-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 14 Mar 2012 00:01:58 -0700
Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrote:

> From: Yi Zou <yi.zou@intel.com>
> 
> Fix a bug when using 'ethtool -K ethx tx off' to turn off tx ip checksum,
> FCoE CRC offload should not be impacte. The skb_checksum_help() is needed
> only if it's not FCoE traffic for ip checksum, regardless of ethtool toggling
> the tx ip checksum on or off.
> 
> Signed-off-by: Yi Zou <yi.zou@intel.com>
> Tested-by: Ross Brattain <ross.b.brattain@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  net/core/dev.c |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 6ca32f6..9e378009 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1913,6 +1913,9 @@ int skb_checksum_help(struct sk_buff *skb)
>  	__wsum csum;
>  	int ret = 0, offset;
>  
> +	if (skb->protocol == htons(ETH_P_FCOE))
> +		goto out;
> +
>  	if (skb->ip_summed == CHECKSUM_COMPLETE)
>  		goto out_set_summed;
>  

Shouldn't this be done in the offending driver rather than the core?
