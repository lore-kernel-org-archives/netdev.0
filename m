From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH iproute2 1/2] utils: add s32 parser
Date: Fri, 25 Nov 2011 09:46:09 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6D8AEE2@saturn3.aculab.com>
References: <1322156415-23331-1-git-send-email-hagen@jauu.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Stephen Hemminger" <shemminger@vyatta.com>
To: "Hagen Paul Pfeifer" <hagen@jauu.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:39986 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751223Ab1KYJsG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2011 04:48:06 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 07333-06 for <netdev@vger.kernel.org>;
 Fri, 25 Nov 2011 09:48:02 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <1322156415-23331-1-git-send-email-hagen@jauu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +int get_s32(__s32 *val, const char *arg, int base)
> +{
> +	long res;
> +	char *ptr;
> +
> +	if (!arg || !*arg)
> +		return -1;

No need to check *arg, picked up below.

> +	res = strtoul(arg, &ptr, base);
> +	if (!ptr || ptr == arg || *ptr || res > INT32_MAX || res <
INT32_MIN)

No need to check !ptr.

> +		return -1;
> +	*val = res;
> +	return 0;
> +}

Seems to me this be commoned with get_s16() by using
a function that takes the bounds as parameters.
Or possibly with a wrapper to strtoul() that does all the
validation checks.

	David
