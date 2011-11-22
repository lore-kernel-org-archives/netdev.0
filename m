From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] xfrm: optimize ipv4 selector matching
Date: Tue, 22 Nov 2011 15:15:25 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6D8AED9@saturn3.aculab.com>
References: <1321974652.2474.27.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: "Eric Dumazet" <eric.dumazet@gmail.com>,
	"Alexey Dobriyan" <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:49155 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753130Ab1KVPRS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2011 10:17:18 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 00579-02 for <netdev@vger.kernel.org>;
 Tue, 22 Nov 2011 15:17:15 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <1321974652.2474.27.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 
> Please use :
> 
> +static inline bool addr4_match(__be32 a1, __be32 a2, u8 prefixlen)
> +{
> +       /* C99 6.5.7 (3): u32 << 32 is undefined behaviour */
> +       if (prefixlen == 0)
> +               return true;
> +       return !((a1 ^ a2) & htonl(0xFFFFFFFFu << (32 - prefixlen)));
> +}

I'm not sure I'd agree about using 'u8'.
It may well cause an unnecessary mask with 0xff.

	David
