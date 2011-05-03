From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] pktgen: use %pI6c for printing IPv6 addresses
Date: Tue, 03 May 2011 16:25:13 -0700
Message-ID: <1304465113.1788.48.camel@Joe-Laptop>
References: <20110503212340.GA25293@p183>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Robert Olsson <robert.olsson@its.uu.se>
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1204 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753946Ab1ECXZO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 May 2011 19:25:14 -0400
In-Reply-To: <20110503212340.GA25293@p183>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-05-04 at 00:23 +0300, Alexey Dobriyan wrote:
> I don't know why %pI6 doesn't compress, but the format specifier is
> kernel-standard, so use it.

Hi again Alexey.

I doubt it matters but the old routine compresses the first
0 it finds rather than the longest consecutive 0 match so
the output could be a bit different.

given:	"0:1:0:0:0:0:0:7"
old:	"::1:0:0:0:0:0:7"
new:	"0:1::7"

I think the patch is an improvement.

> -static unsigned int fmt_ip6(char *s, const char ip[16])
> -{
> -	unsigned int len;
> -	unsigned int i;
> -	unsigned int temp;
> -	unsigned int compressing;
> -	int j;
> -
> -	len = 0;
> -	compressing = 0;
> -	for (j = 0; j < 16; j += 2) {
> -
> -#ifdef V4MAPPEDPREFIX
> -		if (j == 12 && !memcmp(ip, V4mappedprefix, 12)) {
> -			inet_ntoa_r(*(struct in_addr *)(ip + 12), s);
> -			temp = strlen(s);
> -			return len + temp;
> -		}
> -#endif
> -		temp = ((unsigned long)(unsigned char)ip[j] << 8) +
> -		    (unsigned long)(unsigned char)ip[j + 1];
> -		if (temp == 0) {
> -			if (!compressing) {
> -				compressing = 1;
> -				if (j == 0) {
> -					*s++ = ':';
> -					++len;
> -				}
> -			}
> -		} else {
> -			if (compressing) {
> -				compressing = 0;
> -				*s++ = ':';
> -				++len;
> -			}
> -			i = fmt_xlong(s, temp);
> -			len += i;
> -			s += i;
> -			if (j < 14) {
> -				*s++ = ':';
> -				++len;
> -			}
> -		}
> -	}
> -	if (compressing) {
> -		*s++ = ':';
> -		++len;
> -	}
> -	*s = 0;
> -	return len;
> -}


