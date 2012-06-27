From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 2/7] sock_diag: Do not use RTA_PUT() macros
Date: Wed, 27 Jun 2012 11:00:30 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B6F66@saturn3.aculab.com>
References: <aebb990d61eec6d97f1dfe52a0579981c40cce9e.1340788373.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "Thomas Graf" <tgraf@suug.ch>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:41784 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753814Ab2F0KBu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 06:01:50 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 20480-10 for <netdev@vger.kernel.org>;
 Wed, 27 Jun 2012 11:01:48 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <aebb990d61eec6d97f1dfe52a0579981c40cce9e.1340788373.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 
> @@ -35,9 +34,7 @@ EXPORT_SYMBOL_GPL(sock_diag_save_cookie);
>  
>  int sock_diag_put_meminfo(struct sock *sk, struct sk_buff 
> *skb, int attrtype)
>  {
> -	__u32 *mem;
> -
> -	mem = RTA_DATA(__RTA_PUT(skb, attrtype, SK_MEMINFO_VARS *
sizeof(__u32)));
> +	u32 mem[SK_MEMINFO_VARS];

Isn't that likely to blow the kernel stack?

	David
