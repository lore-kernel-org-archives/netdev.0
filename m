From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next?] pktgen: Use simpler test for non-zero ipv6 address
Date: Thu, 11 Oct 2012 09:08:52 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7036@saturn3.aculab.com>
References: <1349894559.2035.12.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "LKML" <linux-kernel@vger.kernel.org>
To: "Joe Perches" <joe@perches.com>, "netdev" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <1349894559.2035.12.camel@joe-AO722>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -		if (pkt_dev->min_in6_daddr.s6_addr32[0] == 0 &&
> -		    pkt_dev->min_in6_daddr.s6_addr32[1] == 0 &&
> -		    pkt_dev->min_in6_daddr.s6_addr32[2] == 0 &&
> -		    pkt_dev->min_in6_daddr.s6_addr32[3] == 0) ;
> -		else {
> +		if (pkt_dev->min_in6_daddr.s6_addr32[0] |
> +		    pkt_dev->min_in6_daddr.s6_addr32[1] |
> +		    pkt_dev->min_in6_daddr.s6_addr32[2] |
> +		    pkt_dev->min_in6_daddr.s6_addr32[3]) {

Given the likely values, it might be worth using:
		if (pkt_dev->min_in6_daddr.s6_addr32[0] == 0 &&
		    pkt_dev->min_in6_daddr.s6_addr32[1] |
		    pkt_dev->min_in6_daddr.s6_addr32[2] |
		    pkt_dev->min_in6_daddr.s6_addr32[3]) {

	David
