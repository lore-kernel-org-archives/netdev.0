From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] (2/4) support large number of network devices -- name
 hash
Date: Thu, 22 Jan 2004 11:10:54 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040122.111054.106114998.yoshfuji@linux-ipv6.org>
References: <20040116154814.7c7f31ac.shemminger@osdl.org>
	<20040117.112244.90941296.yoshfuji@linux-ipv6.org>
	<20040119112850.3b3575a7.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: shemminger@osdl.org
In-Reply-To: <20040119112850.3b3575a7.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20040119112850.3b3575a7.shemminger@osdl.org> (at Mon, 19 Jan 2004 11:28:50 -0800), Stephen Hemminger <shemminger@osdl.org> says:

> Use strnlen, great idea, thanks.

> -	size_t len = min(strlen(name),(size_t)(IFNAMSIZ-1));
> -	unsigned hash = full_name_hash(name, len);
> +	unsigned hash = full_name_hash(name, 
> +				       strnlen(name, IFNAMSIZ-1));

I prefer IFNAMSIZ over IFNAMSIZ-1 here
bacause maximum length of valid name is IFNAMSIZ-1.

strnlen(3):
       size_t strnlen(const char *s, size_t maxlen);
:
       The strnlen function returns strlen(s), if that is less than maxlen, or
       maxlen  if there is no '\0' character among the first maxlen characters
       pointed to by s.

If strnlen(name,IFNAMSIZ) returns IFNAMSIZ, name is not terminated.
while strnlen(name,IFNAMSIZ-1) does not tell whether it is terminated or not.

--yoshfuji
