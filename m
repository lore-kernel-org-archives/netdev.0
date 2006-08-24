From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 2.6.17 0/9] NetXen: 1G/10G Ethernet Driver - patch for big-endian systems
Date: Thu, 24 Aug 2006 23:40:11 +0200
Message-ID: <20060824214011.GA19643@electric-eye.fr.zoreil.com>
References: <Pine.LNX.4.64.0608180713480.6875@dut39> <Pine.LNX.4.64.0608220038580.18115@dut46> <1156451811.13196.132.camel@wendyx.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pradeep Dalvi <pradeep@netxen.com>, netdev@vger.kernel.org,
	"jeff@garzik.org" <jeff@garzik.org>,
	"sanjeev@netxen.com" <sanjeev@netxen.com>,
	"unmproj@linsyssoft.com" <unmproj@linsyssoft.com>,
	Rob Mapes <rob@netxen.com>, amitkale@netxen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:13784 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S1422701AbWHXVoB
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Aug 2006 17:44:01 -0400
To: wen xiong <wendyx@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <1156451811.13196.132.camel@wendyx.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

wen xiong <wendyx@us.ibm.com> :
[...]
> diff -Nuar old/drivers/net/netxen/netxen_nic_hw.c new/drivers/net/netxen/netxen_nic_hw.c
> --- old/drivers/net/netxen/netxen_nic_hw.c	2006-08-23 12:58:43.000000000 -0500
> +++ new/drivers/net/netxen/netxen_nic_hw.c	2006-08-23 13:15:19.000000000 -0500
> @@ -313,7 +313,8 @@
>  		}
>  	}
>  	CMD_DESC_TCP_HDR_OFFSET_WRT(desc, skb->h.raw - skb->data);
> -	desc->ip_hdr_offset = skb->nh.raw - skb->data;
> +	desc->length_tcp_hdr=cpu_to_le32(desc->length_tcp_hdr);

s/=/ = /

(several occurences)

[...]
> diff -Nuar old/drivers/net/netxen/netxen_nic_init.c new/drivers/net/netxen/netxen_nic_init.c
> --- old/drivers/net/netxen/netxen_nic_init.c	2006-08-23 12:58:43.000000000 -0500
> +++ new/drivers/net/netxen/netxen_nic_init.c	2006-08-23 13:15:19.000000000 -0500
> @@ -494,7 +494,7 @@
>  		desc_head = recv_ctx->rcv_status_desc_head;
>  		desc = &desc_head[consumer];
>  
> -		if ((desc->owner & STATUS_OWNER_HOST))
> +		if (((le16_to_cpu(desc->owner)) & STATUS_OWNER_HOST))

Would it make a difference to swab the constant part, i.e.:

	if (desc->owner & cpu_to_le16(STATUS_OWNER_HOST))

-- 
Ueimor
