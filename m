From: Arthur Jones <ajones@riverbed.com>
Subject: Re: [net-next PATCH 1/5] igb: allow tx of pre-formatted vlan
	tagged packets
Date: Fri, 20 Mar 2009 08:27:25 -0700
Message-ID: <20090320152724.GB7395@ajones-laptop.nbttech.com>
References: <20090320101631.17663.63853.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	Arthur Jones <Arthur.Jones@riverbed.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.riverbed.com ([206.169.144.7]:60177 "EHLO
	smtp2.riverbed.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751060AbZCTP12 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2009 11:27:28 -0400
Content-Disposition: inline
In-Reply-To: <20090320101631.17663.63853.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jeff, ...

On Fri, Mar 20, 2009 at 03:16:31AM -0700, Jeff Kirsher wrote:
>  [...]
> 
>  drivers/net/igb/igb_main.c |   11 +++++++++++
>  1 files changed, 11 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
> index 7c4481b..c14d569 100644
> --- a/drivers/net/igb/igb_main.c
> +++ b/drivers/net/igb/igb_main.c
> @@ -3008,6 +3008,17 @@ static inline bool igb_tx_csum_adv(struct igb_adapter *adapter,
>  		tu_cmd |= (E1000_TXD_CMD_DEXT | E1000_ADVTXD_DTYP_CTXT);
>  
>  		if (skb->ip_summed == CHECKSUM_PARTIAL) {
> +			__be16 protocol;
> +
> +			if (skb->protocol == cpu_to_be16(ETH_P_8021Q)) {
> +				const struct vlan_ethhdr *vhdr =
> +				          (const struct vlan_ethhdr*)skb->data;
> +
> +				protocol = vhdr->h_vlan_encapsulated_proto;
> +			} else {
> +				protocol = skb->protocol;
> +			}
> +
>  			switch (skb->protocol) {
                                ^^^^^^^^^^^^^
This has the same merge error as the e1000e version,
it should be just protocol here, not skb->protocol...

Arthur
