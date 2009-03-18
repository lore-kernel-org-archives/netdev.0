From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: iproute2: prints bogus hoplimit
Date: Wed, 18 Mar 2009 15:12:16 -0700
Message-ID: <20090318151216.60cd0363@nehalam>
References: <alpine.LSU.2.00.0902241125020.329@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen.hemminger@vyatta.com>,
	netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:45945 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752718AbZCRWMY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Mar 2009 18:12:24 -0400
In-Reply-To: <alpine.LSU.2.00.0902241125020.329@fbirervta.pbzchgretzou.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 24 Feb 2009 11:27:52 +0100 (CET)
Jan Engelhardt <jengelh@medozas.de> wrote:

> 
> $ ip -6 r
> fc00::/7 dev rtl0  proto kernel  metric 256  mtu 1500 advmss 1440 
> hoplimit 4294967295
> 
> Most likely, "hoplimit -1" would be the right number, though I am not 
> sure if simply changing %u by %d is a correct thing to do, since it 
> would affect all fields.
> 
> ---
>  ip/iproute.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/ip/iproute.c b/ip/iproute.c
> index 6a2ea05..91a8cc0 100644
> --- a/ip/iproute.c
> +++ b/ip/iproute.c
> @@ -507,7 +507,7 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
>  
>  			if (i != RTAX_RTT && i != RTAX_RTTVAR &&
>  			    i != RTAX_RTO_MIN)
> -				fprintf(fp, " %u", *(unsigned*)RTA_DATA(mxrta[i]));
> +				fprintf(fp, " %d", *(unsigned*)RTA_DATA(mxrta[i]));
>  			else {
>  				unsigned long long val = *(unsigned*)RTA_DATA(mxrta[i]);
>  

No fix the kernel please.
