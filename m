From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 1/4] netfilter: ipset: fix timeout value overflow bug
Date: Mon, 14 May 2012 15:19:49 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B6F0B@saturn3.aculab.com>
References: <1336996023-20249-2-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <pablo@netfilter.org>, <netfilter-devel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:49232 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1756258Ab2ENOUW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2012 10:20:22 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 20149-02 for <netdev@vger.kernel.org>;
 Mon, 14 May 2012 15:20:19 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <1336996023-20249-2-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 
> --- a/include/linux/netfilter/ipset/ip_set_timeout.h
> +++ b/include/linux/netfilter/ipset/ip_set_timeout.h
> @@ -30,6 +30,10 @@ ip_set_timeout_uget(struct nlattr *tb)
>  {
>  	unsigned int timeout = ip_set_get_h32(tb);
>  
> +	/* Normalize to fit into jiffies */
> +	if (timeout > UINT_MAX/1000)
> +		timeout = UINT_MAX/1000;
> +

Doesn't that rather assume that HZ is 1000 ?

	David
 
