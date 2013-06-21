From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 5/6] alx: fix MAC address alignment problem
Date: Fri, 21 Jun 2013 09:38:09 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B729E@saturn3.aculab.com>
References: <1371766494-18979-1-git-send-email-johannes@sipsolutions.net> <1371766494-18979-6-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <ben@decadent.org.uk>
To: "Johannes Berg" <johannes@sipsolutions.net>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:49124 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1757862Ab3FUIjL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jun 2013 04:39:11 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 19032-08 for <netdev@vger.kernel.org>;
 Fri, 21 Jun 2013 09:39:05 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <1371766494-18979-6-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> In two places, parts of MAC addresses are used as u32/u16
> values. This can cause alignment problems, use put_unaligned
> and get_unaligned to fix this.

I suspect they are always 16bit aligned, so 16bit accesses
would be ok - rather than using byte accesses.
However I wouldn't know how to request this with the available
definitions....

	David

...
>  	/* addr should be big-endian */
> -	*(__be32 *)(addr + 2) = cpu_to_be32(mac0);
> -	*(__be16 *)addr = cpu_to_be16(mac1);
> +	put_unaligned(cpu_to_be32(mac0), (__be32 *)(addr + 2));
> +	put_unaligned(cpu_to_be16(mac1), (__be16 *)addr);
...
> -	val = be32_to_cpu(*(__be32 *)(addr + 2));
> +	val = be32_to_cpu(get_unaligned((__be32 *)(addr + 2)));
>  	alx_write_mem32(hw, ALX_STAD0, val);
> -	val = be16_to_cpu(*(__be16 *)addr);
> +	val = be16_to_cpu(get_unaligned((__be16 *)addr));
>  	alx_write_mem32(hw, ALX_STAD1, val);
