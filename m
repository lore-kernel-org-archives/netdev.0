From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 6/7] net: ipv4: return route match in GETROUTE
 request
Date: Tue, 10 Jan 2017 20:40:34 -0500 (EST)
Message-ID: <20170110.204034.925090776724245879.davem@davemloft.net>
References: <1483997571-3964-1-git-send-email-dsa@cumulusnetworks.com>
        <1483997571-3964-7-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34026 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753361AbdAKBkg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 20:40:36 -0500
In-Reply-To: <1483997571-3964-7-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Mon,  9 Jan 2017 13:32:50 -0800

> diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
> index 8c93ad1ef9ab..471384b72cea 100644
> --- a/include/uapi/linux/rtnetlink.h
> +++ b/include/uapi/linux/rtnetlink.h
> @@ -319,6 +319,8 @@ enum rtattr_type_t {
>  	RTA_EXPIRES,
>  	RTA_PAD,
>  	RTA_UID,
> +	RTA_ROUTE_GET,  /* nested attribute; route spec for RTM_GETROUTE */
> +	RTA_ROUTE_GET_RTM, /* struct rtmsg for nested spec */
>  	__RTA_MAX
>  };

The nested attribute and the attributes within that nested attribute
live in two different attribute number namespaces.

So usually we allocate the nested attribute at the top level in the
main enumeration.  Then the elements within the nested attribute
get allocated with a new enumeration created specifically for items
inside that nested attribute.

For example, RTA_METRICS --> RTAX_*

So please arrange things this way.

Thanks.
