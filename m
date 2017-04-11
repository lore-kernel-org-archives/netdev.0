From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH iproute2 net-next 1/2] iproute: Add support for
 ttl-propagation attribute
Date: Mon, 10 Apr 2017 21:43:53 -0600
Message-ID: <08e2c6b8-0910-0d0b-39a4-887a0d3e4f94@cumulusnetworks.com>
References: <1491834972-26668-1-git-send-email-rshearma@brocade.com>
 <1491834972-26668-2-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org
To: Robert Shearman <rshearma@brocade.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f53.google.com ([74.125.83.53]:36046 "EHLO
        mail-pg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751101AbdDKDn4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Apr 2017 23:43:56 -0400
Received: by mail-pg0-f53.google.com with SMTP id g2so114160884pge.3
        for <netdev@vger.kernel.org>; Mon, 10 Apr 2017 20:43:56 -0700 (PDT)
In-Reply-To: <1491834972-26668-2-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/10/17 8:36 AM, Robert Shearman wrote:
> @@ -1184,6 +1192,20 @@ static int iproute_modify(int cmd, unsigned int flags, int argc, char **argv)
>  
>  			if (rta->rta_len > RTA_LENGTH(0))
>  				addraw_l(&req.n, 1024, RTA_DATA(rta), RTA_PAYLOAD(rta));
> +		} else if (strcmp(*argv, "ttl-propagate") == 0) {
> +			__u8 ttl_prop;
> +
> +			NEXT_ARG();
> +			if (strcmp(*argv, "enabled") == 0)
> +				ttl_prop = 1;
> +			else if (strcmp(*argv, "disabled") == 0)
> +				ttl_prop = 0;
> +			else
> +				invarg("\"ttl-propagate\" value is invalid\n",
> +				       *argv);
> +

matches() instead of strcmp() is more user friendly. 'enabled' is a lot
to type. ;-)
