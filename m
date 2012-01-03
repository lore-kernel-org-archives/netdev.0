From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 0/4] skb paged fragment destructors
Date: Tue, 3 Jan 2012 09:36:33 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6D8AF27@saturn3.aculab.com>
References: <1324632922.7877.103.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <eric.dumazet@gmail.com>, <jesse.brandeburg@intel.com>,
	<netdev@vger.kernel.org>
To: "Ian Campbell" <Ian.Campbell@citrix.com>,
	"David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:38734 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751627Ab2ACJiS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2012 04:38:18 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 23550-03 for <netdev@vger.kernel.org>;
 Tue,  3 Jan 2012 09:38:15 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <1324632922.7877.103.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 
> -#if (65536/PAGE_SIZE + 2) < 16
> +#if (65536/PAGE_SIZE + 1) < 16
>  #define MAX_SKB_FRAGS 16UL
>  #else
> -#define MAX_SKB_FRAGS (65536/PAGE_SIZE + 2)
> +#define MAX_SKB_FRAGS (65536/PAGE_SIZE + 1)
>  #endif

Wouldn't it be better to only have the expression once?
Either using a MAX() define or maybe:

#define MAX_SKB_FRAGS (65536UL/PAGE_SIZE + 1)
#if MAX_SKB_FRAGS < 16UL
#undef MAX_SKB_FRAGS
#define MAX_SKB_FRAGS 16UL
#endif

Although that replicates the 16 instead :-(

	David
