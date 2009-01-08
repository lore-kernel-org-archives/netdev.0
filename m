From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH] hdlc: fix compile problem
Date: Thu, 08 Jan 2009 02:26:31 +0100
Message-ID: <m3priytwoo.fsf@maximus.localdomain>
References: <20090107141343.3e256119@extreme>
	<m3d4eyvh28.fsf@maximus.localdomain> <20090107152858.6fb8ac5d@extreme>
	<m3tz8atxwv.fsf@maximus.localdomain> <20090107170842.6ee4eb77@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:36472 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755209AbZAHB0g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jan 2009 20:26:36 -0500
In-Reply-To: <20090107170842.6ee4eb77@extreme> (Stephen Hemminger's message of "Wed\, 7 Jan 2009 17\:08\:42 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <shemminger@vyatta.com> writes:

> Alternatively, how about this:
>
> --- a/drivers/net/wan/hdlc.c	2009-01-07 17:04:52.002497019 -0800
> +++ b/drivers/net/wan/hdlc.c	2009-01-07 17:07:02.874497531 -0800
> @@ -40,8 +40,6 @@
>  
>  static const char* version = "HDLC support module revision 1.22";
>  
> -static const struct header_ops hdlc_null_ops;
> -
>  #undef DEBUG_LINK
>  
>  static struct hdlc_proto *first_proto;
> @@ -100,7 +98,7 @@ static int hdlc_device_event(struct noti
>  	if (dev_net(dev) != &init_net)
>  		return NOTIFY_DONE;
>  
> -	if (dev->header_ops != &hdlc_null_ops)
> +	if (dev->priv_flags & IFF_WAN_HDLC)
>  		return NOTIFY_DONE; /* not an HDLC device */
>  
>  	if (event != NETDEV_CHANGE)

"dev->netdev_ops->start_hard_xmit != hdlc_xmit" is a dirty hack.
IFF_WAN_HDLC is much cleaner though it's an additional bit consumed.
Sure, I like it.
-- 
Krzysztof Halasa
