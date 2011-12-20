From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 1/1] tcp: Replace constants with #define macros
Date: Tue, 20 Dec 2011 10:27:21 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6D8AF1C@saturn3.aculab.com>
References: <1324351929-2588-1-git-send-email-subramanian.vijay@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>,
	"Eric Dumazet" <eric.dumazet@gmail.com>,
	<ilpo.jarvinen@helsinki.fi>, "H.K. Jerry Chu" <hkchu@google.com>
To: "Vijay Subramanian" <subramanian.vijay@gmail.com>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:45770 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1750734Ab1LTK27 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2011 05:28:59 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 18387-05 for <netdev@vger.kernel.org>;
 Tue, 20 Dec 2011 10:28:49 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <1324351929-2588-1-git-send-email-subramanian.vijay@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 
> diff --git a/include/linux/tcp.h b/include/linux/tcp.h
> index 7f59ee9..874b043 100644
> --- a/include/linux/tcp.h
> +++ b/include/linux/tcp.h
> @@ -238,6 +238,11 @@ struct tcp_sack_block {
>  	u32	end_seq;
>  };
>  
> +/*These are used to set the sack_ok field in struct 
> tcp_options_received */
> +#define SACK_SEEN     (1 << 0)   /*1 = peer is SACK capable, */
> +#define FACK_ENABLED  (1 << 1)   /*1 = FACK is enabled locally*/
> +#define DSACK_SEEN    (1 << 2)   /*1 = DSACK was received from peer*/
> +

Since that is a fairly public header, some namespace protection
might be sensible.

> -	tcp_opt->sack_ok = (options >> 4) & 0x1;
> +	tcp_opt->sack_ok = (options >> 4) & SACK_SEEN;

Looks to me like that 0x1 isn't SAC_SEEK! So this is now misleading.

	David
