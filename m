From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [iproute PATCH 05/12] ip{,6}tunnel: align do_tunnels_list() a
 bit
Date: Fri, 13 Nov 2015 17:30:10 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CBD1126@AcuExch.aculab.com>
References: <1447434545-32182-1-git-send-email-phil@nwl.cc>
 <1447434545-32182-6-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Phil Sutter' <phil@nwl.cc>,
	Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.195]:61617 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754719AbbKMRbd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2015 12:31:33 -0500
In-Reply-To: <1447434545-32182-6-git-send-email-phil@nwl.cc>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Sutter
> Sent: 13 November 2015 17:09
> In iptunnel, declare loop variables inside the loop as done in
> ip6tunnel.
...
> @@ -396,14 +396,8 @@ static void print_tunnel(struct ip_tunnel_parm *p)
> 
>  static int do_tunnels_list(struct ip_tunnel_parm *p)
>  {
> -	char name[IFNAMSIZ];
> -	unsigned long  rx_bytes, rx_packets, rx_errs, rx_drops,
> -	rx_fifo, rx_frame,
> -	tx_bytes, tx_packets, tx_errs, tx_drops,
> -	tx_fifo, tx_colls, tx_carrier, rx_multi;
> -	struct ip_tunnel_parm p1;
> -
...
>  	while (fgets(buf, sizeof(buf), fp) != NULL) {
> +		char name[IFNAMSIZ];
>  		int index, type;
> +		unsigned long rx_bytes, rx_packets, rx_errs, rx_drops,
> +			rx_fifo, rx_frame,
> +			tx_bytes, tx_packets, tx_errs, tx_drops,
> +			tx_fifo, tx_colls, tx_carrier, rx_multi;
> +		struct ip_tunnel_parm p1;
>  		char *ptr;
> +

Personally I find that just makes it harder to find where the
variables are defined.
Since the linux kernel cannot be compiled with -Wshadow declaring
variables in inner scopes can easily lead to very strange bugs.

	David
