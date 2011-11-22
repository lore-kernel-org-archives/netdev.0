From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] xfrm: optimize ipv4 selector matching
Date: Tue, 22 Nov 2011 14:50:59 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6D8AED7@saturn3.aculab.com>
References: <20111122144334.GA22824@p183.telecom.by>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "Alexey Dobriyan" <adobriyan@gmail.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:48592 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1755482Ab1KVOww convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2011 09:52:52 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 26171-06 for <netdev@vger.kernel.org>;
 Tue, 22 Nov 2011 14:52:49 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <20111122144334.GA22824@p183.telecom.by>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 
> +static inline int addr4_match(const __be32 a1, const __be32 
> a2, const u8 prefixlen)
> +{
> +	/* C99 6.5.7 (3): u32 << 32 is undefined behaviour */
> +	if (prefixlen == 0) {
> +		/* Matching constants result in smaller assembly. */
> +		return 0xFFFFFFFFu;
> +	}
> +	return !((a1 ^ a2) & htonl(0xFFFFFFFFu << (32 - prefixlen)));
> +}
> +

It would probably be clearer to 'return 1' when prefixlen is zero.

If this is a common path, might be worth caching
    htonl(0xFFFFFFFFu << (32 - prefixlen))
in the enclosing structure.

	David
