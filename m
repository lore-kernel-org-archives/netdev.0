From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 2/2] NetXen: Updates for register access routines
Date: Wed, 2 May 2007 22:31:46 +0200
Message-ID: <20070502203146.GA17833@electric-eye.fr.zoreil.com>
References: <Pine.LNX.4.64.0705020815260.3154@dut46>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev mailing list <netdev@vger.kernel.org>,
	netxenproj@linsyssoft.com, Jeff Garzik <jeff@garzik.org>,
	rob@netxen.com
To: Mithlesh Thukral <mithlesh@netxen.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:54391 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1766839AbXEBUek (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 May 2007 16:34:40 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0705020815260.3154@dut46>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mithlesh Thukral <mithlesh@netxen.com> :
[...]
> diff --git a/drivers/net/netxen/netxen_nic.h 
> b/drivers/net/netxen/netxen_nic.h
> index ad6688e..71edb5c 100644
> --- a/drivers/net/netxen/netxen_nic.h
> +++ b/drivers/net/netxen/netxen_nic.h
> @@ -302,29 +302,28 @@ #define FLAGS_IPSEC_SA_ADD	0x04
[...]
> -#define netxen_set_cmd_desc_num_of_buff(cmd_desc, val)	\
> -	((cmd_desc)->num_of_buffers_total_length &= ~cpu_to_le32(0xff), \
> -	(cmd_desc)->num_of_buffers_total_length |= cpu_to_le32((val) & 0xff))
> -#define netxen_set_cmd_desc_totallength(cmd_desc, val)	\
> -	((cmd_desc)->num_of_buffers_total_length &= 
> ~cpu_to_le32(0xffffff00), \
> -	(cmd_desc)->num_of_buffers_total_length |= cpu_to_le32(val << 8))
> +#define netxen_set_cmd_desc_num_of_buff(cmd_desc, val)                 \
> +	((cmd_desc)->num_of_buffers_total_length &= ~(0xff<<0),         \
> +	(cmd_desc)->num_of_buffers_total_length |= (val & 0xff)<<0)

The cpu_to_leXY have disappeared but the fields of the struct are
still annotated with __le. Is sparse happy with it ?

-- 
Ueimor

Anybody got a battery for my Ultra 10 ?
