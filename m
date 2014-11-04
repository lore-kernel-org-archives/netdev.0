From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v2 1/1] ip-link: in human readable output use dynamic
 precision length
Date: Tue, 4 Nov 2014 11:06:50 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1C9E72A7@AcuExch.aculab.com>
References: <20141104114421.6a7f9de5@leda.localdomain>
 <1415098208-17942-1-git-send-email-mail@eworm.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Christian Hesse' <mail@eworm.de>,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:41884 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752557AbaKDLJj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2014 06:09:39 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 24979-01 for <netdev@vger.kernel.org>;
 Tue,  4 Nov 2014 11:09:26 +0000 (GMT)
In-Reply-To: <1415098208-17942-1-git-send-email-mail@eworm.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christian Hesse
...
> diff --git a/ip/ipaddress.c b/ip/ipaddress.c
> index e240bb5..55cbc77 100644
> --- a/ip/ipaddress.c
> +++ b/ip/ipaddress.c
> @@ -324,6 +324,7 @@ static void print_num(FILE *fp, unsigned width, uint64_t count)
>  	const char *prefix = "kMGTPE";
>  	const unsigned int base = use_iec ? 1024 : 1000;
>  	uint64_t powi = 1;
> +	int precision;
>  	char buf[64];
> 
>  	if (!human_readable || count < base) {
> @@ -343,8 +344,11 @@ static void print_num(FILE *fp, unsigned width, uint64_t count)
>  		++prefix;
>  	}
> 
> -	snprintf(buf, sizeof(buf), "%.1f%c%s", (double) count / powi,
> -		 *prefix, use_iec ? "i" : "");
> +	if ((precision = 3 - snprintf(NULL, 0, "%"PRIu64, count / powi)) < 0)

Don't put assignments in conditionals.

> +		precision = 0;
> +
> +	snprintf(buf, sizeof(buf), "%.*f%c%s", precision,
> +		(double) count / powi, *prefix, use_iec ? "i" : "");
> 
>  	fprintf(fp, "%-*s ", width, buf);
>  }
> --
> 2.1.3

The above will go wrong in all sorts of horrid ways....
For instance you are doing a truncating integer divide, but the FP
value will get rounded for display.

It would be safer to use integers throughout.

Oh, and a 2Mbit E1 link is actually 2048000 :-)

	David
