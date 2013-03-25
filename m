From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 3/3] dsa: fix freeing of sparse port allocation
Date: Mon, 25 Mar 2013 16:03:23 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B71B3@saturn3.aculab.com>
References: <1364223820-26051-1-git-send-email-florian@openwrt.org> <1364223820-26051-4-git-send-email-florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "Florian Fainelli" <florian@openwrt.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:60245 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1758453Ab3CYQMn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Mar 2013 12:12:43 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 21525-07 for <netdev@vger.kernel.org>;
 Mon, 25 Mar 2013 16:12:39 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <1364223820-26051-4-git-send-email-florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> If we have defined a sparse port allocation which is non-contiguous and
> contains gaps, the code freeing port_names will just stop when it
> encouters a first NULL port_names, which is not right, we should iterate
> over all possible number of ports (DSA_MAX_PORTS) until we are done.
...
>  		port_index = 0;
> -		while (pd->chip[i].port_names &&
> -			pd->chip[i].port_names[++port_index])
> -			kfree(pd->chip[i].port_names[port_index]);
> +		while (port_index < DSA_MAX_PORTS) {
> +			if (pd->chip[i].port_names[port_index])
> +				kfree(pd->chip[i].port_names[port_index]);
> +			port_index++;
> +		}

A couple of 'odd' differences:

The old code checked pd->chip[i].port_names (as if it
might be a pointer) that is absent from the new version.
(If it is separately allocated it is leaked).

The new code tests and frees pd->chip[i].port_names[0]
whereas the old code ignored the 0th entry.

These may, or may not, be relevant!

	David
