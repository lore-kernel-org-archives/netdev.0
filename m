From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 1/2] lib: vsprintf: add IPv4/v6 generic
 %pig/%pIg format specifier
Date: Wed, 26 Jun 2013 18:05:04 -0700
Message-ID: <1372295104.2172.26.camel@joe-AO722>
References: <1372266073-11998-1-git-send-email-dborkman@redhat.com>
	 <1372266073-11998-2-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:52974 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751731Ab3F0BFG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Jun 2013 21:05:06 -0400
In-Reply-To: <1372266073-11998-2-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-06-26 at 19:01 +0200, Daniel Borkmann wrote:
> In order to avoid making code that deals with printing both, IPv4 and
> IPv6 addresses, unnecessary complicated as for example ...
> 
>   if (sa.sa_family == AF_INET6)
>     printk("... %pI6 ...", sin6_addr);
>   else
>     printk("... %pI4 ...", sin_addr.s_addr);
[]
> diff --git a/lib/vsprintf.c b/lib/vsprintf.c
[]
> @@ -1093,6 +1093,18 @@ char *pointer(const char *fmt, char *buf, char *end, void *ptr,
[]
> +		case 'g':
> +			{

This is overly indented.

Just use:
		case 'g': {
			etc...

(%pig looks poorly named though)

I'd prefer "%piS" for "struct sockaddr"

Some other options might be to add port, flowinfo or scope,

See: http://patchwork.ozlabs.org/patch/31480/
