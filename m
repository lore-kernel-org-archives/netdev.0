From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute PATCH v2 4/7] lib/inet_proto: Make sure destination
 buffers are NULL-terminated
Date: Fri, 18 Aug 2017 09:37:33 -0700
Message-ID: <20170818093734.705f6742@xeon-e3>
References: <20170817170932.24659-1-phil@nwl.cc>
        <20170817170932.24659-5-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f51.google.com ([74.125.83.51]:36390 "EHLO
        mail-pg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750984AbdHRQhm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 12:37:42 -0400
Received: by mail-pg0-f51.google.com with SMTP id i12so67642234pgr.3
        for <netdev@vger.kernel.org>; Fri, 18 Aug 2017 09:37:42 -0700 (PDT)
In-Reply-To: <20170817170932.24659-5-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 17 Aug 2017 19:09:29 +0200
Phil Sutter <phil@nwl.cc> wrote:

> Signed-off-by: Phil Sutter <phil@nwl.cc>
> ---
>  lib/inet_proto.c | 9 ++++++---
>  1 file changed, 6 insertions(+), 3 deletions(-)
> 
> diff --git a/lib/inet_proto.c b/lib/inet_proto.c
> index ceda082b12a2e..87ed4769fc3da 100644
> --- a/lib/inet_proto.c
> +++ b/lib/inet_proto.c
> @@ -35,8 +35,10 @@ const char *inet_proto_n2a(int proto, char *buf, int len)
>  	pe = getprotobynumber(proto);
>  	if (pe) {
>  		icache = proto;
> -		strncpy(ncache, pe->p_name, 16);
> -		strncpy(buf, pe->p_name, len);
> +		strncpy(ncache, pe->p_name, 15);
> +		ncache[15] = '\0';
> +		strncpy(buf, pe->p_name, len - 1);
> +		buf[len] = '\0';
>  		return buf;
>  	}
>  	snprintf(buf, len, "ipproto-%d", proto);
> @@ -62,7 +64,8 @@ int inet_proto_a2n(const char *buf)
>  	pe = getprotobyname(buf);
>  	if (pe) {
>  		icache = pe->p_proto;
> -		strncpy(ncache, pe->p_name, 16);
> +		strncpy(ncache, pe->p_name, 15);
> +		ncache[15] = '\0';
>  		return pe->p_proto;
>  	}
>  	return -1;

Depending on proto name to be 15 characters or less is a silly
choice. Why not use strdup() and do it right?
