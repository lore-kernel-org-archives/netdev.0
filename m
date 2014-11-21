From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC PATCH 1/4] rtnetlink: new flag NLM_F_HW_OFFLOAD to indicate
 kernel object offload to hardware
Date: Fri, 21 Nov 2014 23:12:34 +0000
Message-ID: <20141121231234.GA20810@casper.infradead.org>
References: <1416610170-21224-2-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jiri@resnulli.us, sfeldma@gmail.com, jhs@mojatatu.com,
	bcrl@kvack.org, john.fastabend@gmail.com,
	stephen@networkplumber.org, linville@tuxdriver.com,
	nhorman@tuxdriver.com, nicolas.dichtel@6wind.com,
	vyasevic@redhat.com, f.fainelli@gmail.com, buytenh@wantstofly.org,
	aviadr@mellanox.com, netdev@vger.kernel.org, davem@davemloft.net,
	shrijeet@cumulusnetworks.com, gospo@cumulusnetworks.com
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:60030 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751622AbaKUXMm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2014 18:12:42 -0500
Content-Disposition: inline
In-Reply-To: <1416610170-21224-2-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/21/14 at 02:49pm, roopa@cumulusnetworks.com wrote:
> diff --git a/include/uapi/linux/netlink.h b/include/uapi/linux/netlink.h
> index 1a85940..f78522d 100644
> --- a/include/uapi/linux/netlink.h
> +++ b/include/uapi/linux/netlink.h
> @@ -54,6 +54,8 @@ struct nlmsghdr {
>  #define NLM_F_ACK		4	/* Reply with ack, with zero or error code */
>  #define NLM_F_ECHO		8	/* Echo this request 		*/
>  #define NLM_F_DUMP_INTR		16	/* Dump was inconsistent due to sequence change */
> ++#define NLM_F_KERNEL       32      /* This msg is only for the kernel */
> +#define NLM_F_HW_OFFLOAD	64	/* offload this msg to hw */
>  
>  /* Modifiers to GET request */
>  #define NLM_F_ROOT	0x100	/* specify tree	root	*/

The NLM_F_ flag space applies to all Netlink messages including non
networking bits and is reserved for flags vital to the functioning
of the Netlink protocol itself. I suggest you move this to a
RTNETLINK specific flags space.
