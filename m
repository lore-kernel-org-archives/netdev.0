From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH net-next-2.6 v4 02/12] net-caif: add CAIF socket and
 configuration headers
Date: Sat, 27 Feb 2010 00:15:15 +0100
Message-ID: <1267226115.18491.71.camel@violet>
References: <1267222417-2764-1-git-send-email-sjur.brandeland@stericsson.com>
	 <1267222417-2764-2-git-send-email-sjur.brandeland@stericsson.com>
	 <1267222417-2764-3-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	daniel.martensson@stericsson.com, kaber@trash.net,
	stefano.babic@babic.homelinux.org, randy.dunlap@oracle.com
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:36004 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966524Ab0BZXNc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 18:13:32 -0500
In-Reply-To: <1267222417-2764-3-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sjur,

I think most issues have been resolved and this should be ready for
merging, but I am bit worried about the userspace API. Can we start a
bit smaller and extend it later? Especially the socket options worry me
a bit.

Dave, personally I would prefer if we can merge this without these
socket options. Since I am really missing the need for it.

> +/**
> + * enum caif_socket_opts - CAIF option values for getsockopt and setsockopt.
> + *
> + * @CAIFSO_LINK_SELECT:		Selector used if multiple CAIF Link layers are
> + *				available. Either a high bandwidth
> + *				link can be selected (CAIF_LINK_HIGH_BANDW) or
> + *				or a low latency link (CAIF_LINK_LOW_LATENCY).
> + *                              This option is of type u_int32_t.
> + *				Alternatively SO_BINDTODEVICE can be used.
> + *
> + * @CAIFSO_REQ_PARAM:		Used to set the request parameters for a
> + *				utility channel. (struct caif_param). This
> + *				option must be set before connecting.
> + *
> + * @CAIFSO_RSP_PARAM:		Gets the request parameters for a utility
> + *				channel. (struct caif_param). This option
> + *				is valid after a successful connect.

These two more look like a combination of setsockopt/getsockopt instead
of two socket options. Maybe it is leftover from a ioctl interface, but
socket options work differently.

Also the caif_param struct seems pointless. Socket options contain a
length parameter anyway. So why bother with a struct that is just a data
field and a length field.

> + * @CAIFSO_CHANNEL_ID:		Gets the channel id on a CAIF Channel.
> + *				This option is valid after a successful connect.
> + *				( u_int32_t)

Where is this used and what is it used for? Is this something that
shouldn't be better part of the sockaddr structure. Then you can use
getpeername for it?

> + * @CAIFSO_NEXT_PAKCET_LEN:	Gets the size of next received packet.
> + *				Value is 0 if no packet is available.
> + *				This option is valid after a successful connect.
> + *				( u_int32_t)

Typo. And why do we need this?

> + * @CAIFSO_MAX_PAKCET_LEN:	Gets the maximum packet size for this
> + *				connection. ( u_int32_t)

Isn't this more like SO_RCVBUF or SO_SNDBUF.

Regards

Marcel


