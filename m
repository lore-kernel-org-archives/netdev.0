From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next] net/hsr: Added support for HSR v1
Date: Tue, 19 Apr 2016 08:21:00 -0700
Message-ID: <20160419082100.237f1b6e@xeon-e3>
References: <20160413115222.GA42572@aircraft-controller>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: arvid.brodin@alten.se, davem@davemloft.net,
	hannes@stressinduktion.org, sd@queasysnail.net, henrik@austad.us,
	nikolay@cumulusnetworks.com, tgraf@suug.ch, linville@tuxdriver.com,
	gospo@cumulusnetworks.com, dsa@cumulusnetworks.com,
	eranbe@mellanox.com, ast@plumgrid.com, netdev@vger.kernel.org,
	peter.heise@airbus.com
To: Peter Heise <mail@pheise.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f173.google.com ([209.85.223.173]:35124 "EHLO
	mail-io0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932106AbcDSPU6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2016 11:20:58 -0400
Received: by mail-io0-f173.google.com with SMTP id g185so22015714ioa.2
        for <netdev@vger.kernel.org>; Tue, 19 Apr 2016 08:20:53 -0700 (PDT)
In-Reply-To: <20160413115222.GA42572@aircraft-controller>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 13 Apr 2016 13:52:22 +0200
Peter Heise <mail@pheise.de> wrote:

> diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
> index 9427f17..bb3a90b 100644
> --- a/include/uapi/linux/if_link.h
> +++ b/include/uapi/linux/if_link.h
> @@ -773,6 +773,7 @@ enum {
>  	IFLA_HSR_SLAVE1,
>  	IFLA_HSR_SLAVE2,
>  	IFLA_HSR_MULTICAST_SPEC,	/* Last byte of supervision addr */
> +	IFLA_HSR_VERSION,		/* HSR version */
>  	IFLA_HSR_SUPERVISION_ADDR,	/* Supervision frame multicast addr */
>  	IFLA_HSR_SEQ_NR,

You added a new value into the middle of an enumeration field.
This breaks kernel ABI. Older applications (like iproute) would see the wrong
values.

Please submit a new change which moves HSR_VERSION to the end of the enum
