From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH net-next-2.6 02/13] net-caif: add CAIF header files
Date: Fri, 22 Jan 2010 08:51:59 +0100
Message-ID: <1264146719.3469.5.camel@violet>
References: <1264028130-14364-1-git-send-email-sjur.brandeland@stericsson.com>
	 <1264028130-14364-3-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	stefano.babic@babic.homelinux.org, randy.dunlap@oracle.com
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:41709 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752027Ab0AVHu6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jan 2010 02:50:58 -0500
In-Reply-To: <1264028130-14364-3-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sjur,

> +/**
> + * struct sockaddr_caif - the sockaddr structure for CAIF sockets.
> + * @u:			     Union of address data 'switched' by familty.
> + * @at:			     Applies when family = CAIFPROTO_AT.
> + * @at.type:		     Type of AT link to set up (enum caif_at_type).
> + * @util:		     Applies when family = CAIFPROTO_UTIL
> + * @util.service:	     Service name.
> + * @dgm:		     Applies when family = CAIFPROTO_DATAGRAM
> + * @dgm.connection_id:	     Datagram connection id.
> + * @dgm.nsapi:		     NSAPI of the PDP-Context.
> + * @rfm:		     Applies when family = CAIFPROTO_RFM
> + * @rfm.connection_id:       Connection ID for RFM.
> + * @rfm.volume:	     	     Volume to mount.
> + */
> +struct sockaddr_caif {
> +	sa_family_t  family;
> +	union {
> +		struct {
> +			u_int8_t  type;		/* type: enum caif_at_type */
> +		} at;				/* CAIFPROTO_AT */
> +		struct {
> +			char	  service[16];
> +		} util;				/* CAIFPROTO_UTIL */
> +		union {
> +			u_int32_t connection_id;
> +			u_int8_t  nsapi;
> +		} dgm;				/* CAIFPROTO_DATAGRAM(_LOOP)*/
> +		struct {
> +			u_int32_t connection_id;
> +			char	  volume[16];
> +		} rfm;				/* CAIFPROTO_RFM */
> +	} u;
> +};

as mentioned on the oFono mailing list, what is the right procedure to
select a local CAIF device for usage with doing bing(). The use case I
am thinking of is that you have multiple CAIF device attached to the
same system. Think of desktops with USB or even Dual-SIM phones. Before
we set the API in stone, we need to have a way o bind the socket to a
specific device. Maybe it is possible, but I am missing it.

Regards

Marcel


