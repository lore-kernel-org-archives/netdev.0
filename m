From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [iproute PATCH 1/6] utils: Implement strlcpy() and strlcat()
Date: Mon, 4 Sep 2017 14:49:20 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD006D878@AcuExch.aculab.com>
References: <20170901165256.21459-1-phil@nwl.cc>
 <20170901165256.21459-2-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Phil Sutter' <phil@nwl.cc>,
        Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.192]:54145 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753662AbdIDOtZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 4 Sep 2017 10:49:25 -0400
In-Reply-To: <20170901165256.21459-2-phil@nwl.cc>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Sutter
> Sent: 01 September 2017 17:53
> By making use of strncpy(), both implementations are really simple so
> there is no need to add libbsd as additional dependency.
> 
...
> +
> +size_t strlcpy(char *dst, const char *src, size_t size)
> +{
> +	if (size) {
> +		strncpy(dst, src, size - 1);
> +		dst[size - 1] = '\0';
> +	}
> +	return strlen(src);
> +}

Except that isn't really strlcpy().
Better would be:
	len = strlen(src) + 1;
	if (len <= size)
		memcpy(dst, src, len);
	else if (size) {
		dst[size - 1] = 0;
		memcpy(dst, src, size - 1);
	}
	return len - 1;

WTF strlcpy() has that return value I don't know.

	David
