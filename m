From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH V2 resend] ipv6: fix incorrect route 'expires' value passed to userspace
Date: Fri, 20 Jul 2012 11:32:05 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B6F9C@saturn3.aculab.com>
References: <5003CC41.9080204@cn.fujitsu.com> <20120716.025649.1070277404591664104.davem@davemloft.net> <50076AD3.1060604@cn.fujitsu.com> <20120719.104906.38765587582698093.davem@davemloft.net> <5008B794.7010904@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <shemminger@vyatta.com>
To: "Li Wei" <lw@cn.fujitsu.com>, "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:33380 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1750782Ab2GTKlj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2012 06:41:39 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 32033-07 for <netdev@vger.kernel.org>;
 Fri, 20 Jul 2012 11:41:31 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <5008B794.7010904@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -	else if (rt->dst.expires - jiffies < INT_MAX)
> -		expires = rt->dst.expires - jiffies;
> +	else if ((long)rt->dst.expires - (long)jiffies > INT_MIN
> +			&& (long)rt->dst.expires - (long)jiffies <
INT_MAX)
> +		expires = (long)rt->dst.expires - (long)jiffies;
>  	else
> -		expires = INT_MAX;
> +		expires = time_is_after_jiffies(rt->dst.expires) ?
INT_MAX : INT_MIN;

I can't help feeling there is a better way to do this.
Maybe:
	long expires = rt->dst.expires - jiffies;
	if (expires != (int)expires)
		expires = expires > 0 ? INT_MAX : INT_MIN;
Although maybe -INT_MAX instead of INT_MIN.

	David
