From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] vxlan: Update hard_header_len based on lowerdev when
 instantiating VXLAN
Date: Tue, 13 Nov 2012 15:12:00 -0800
Message-ID: <20121113151200.16afce74@nehalam.linuxnetplumber.net>
References: <20121113133353.227ec987@nehalam.linuxnetplumber.net>
	<20121113230955.16102.62399.stgit@ahduyck-cp1.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:33046 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752680Ab2KMXNC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Nov 2012 18:13:02 -0500
In-Reply-To: <20121113230955.16102.62399.stgit@ahduyck-cp1.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 13 Nov 2012 15:10:59 -0800
Alexander Duyck <alexander.h.duyck@intel.com> wrote:

> In the event of a VXLAN device being linked to a device that has a
> hard_header_len greater than that of standard ethernet we could end up with
> the hard_header_len not being large enough for outgoing frames.  In order to
> prevent this we should update the length when a lowerdev is provided.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> ---
> 
>  drivers/net/vxlan.c |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index 44bcc20..6b666eb 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -1110,6 +1110,10 @@ static int vxlan_newlink(struct net *net, struct net_device *dev,
>  
>  		if (!tb[IFLA_MTU])
>  			dev->mtu = lowerdev->mtu - VXLAN_HEADROOM;
> +
> +		/* update header length based on lower device */
> +		dev->hard_header_len = lowerdev->hard_header_len +
> +				       VXLAN_HEADROOM;
>  	}
>  
>  	if (data[IFLA_VXLAN_TOS])
> 

Acked-by: Stephen Hemminger <shemminger@vyatta.com>
