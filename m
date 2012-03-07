From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [patch 4/7] [PATCH] ctcm: make ctcmpc debugging compilable
Date: Wed, 7 Mar 2012 12:20:05 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B6E90@saturn3.aculab.com>
References: <20120307120707.933695671@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <linux-s390@vger.kernel.org>,
	"Ursula Braun" <ursula.braun@de.ibm.com>
To: <frank.blaschka@de.ibm.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:50696 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1757778Ab2CGMU7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Mar 2012 07:20:59 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 09502-01 for <netdev@vger.kernel.org>;
 Wed,  7 Mar 2012 12:20:56 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <20120307120707.933695671@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>  static const struct xid2 init_xid = {
> @@ -132,7 +132,7 @@ void ctcmpc_dumpit(char *buf, int len)
>  	__u32	ct, sw, rm, dup;
>  	char	*ptr, *rptr;
>  	char	tbuf[82], tdup[82];
> -	#if (UTS_MACHINE == s390x)
> +	#ifdef CONFIG_64BIT
>  	char	addr[22];
>  	#else
>  	char	addr[12];
> @@ -149,8 +149,8 @@ void ctcmpc_dumpit(char *buf, int len)
>  
>  	for (ct = 0; ct < len; ct++, ptr++, rptr++) {
>  		if (sw == 0) {
> -			#if (UTS_MACHINE == s390x)
> -			sprintf(addr, "%16.16lx", (__u64)rptr);
> +			#ifdef CONFIG_64BIT
> +			sprintf(addr, "%16.16llx", (__u64)rptr);
>  			#else
>  			sprintf(addr, "%8.8X", (__u32)rptr);
>  			#endif

What is wrong with:
	char addr[24];
	snprintf(addr, sizeof addr, "%p", rptr);

There seemed to be other 'dangerous' unbounded string
operations in that code as well.

	David
