From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH/RFC iproute2 2/3] iptunnel: add support for mpls/ip to sit
 tunnels
Date: Tue, 2 Aug 2016 18:48:37 -0600
Message-ID: <1c808da7-3dc7-b963-03c1-9516ef503ba9@cumulusnetworks.com>
References: <1467829398-4601-1-git-send-email-simon.horman@netronome.com>
 <1467829398-4601-3-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org
To: Simon Horman <simon.horman@netronome.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:35126 "EHLO
	mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756121AbcHCAzX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Aug 2016 20:55:23 -0400
Received: by mail-pf0-f177.google.com with SMTP id x72so71434319pfd.2
        for <netdev@vger.kernel.org>; Tue, 02 Aug 2016 17:54:45 -0700 (PDT)
In-Reply-To: <1467829398-4601-3-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/6/16 12:23 PM, Simon Horman wrote:
> Signed-off-by: Simon Horman <simon.horman@netronome.com>
> ---
>  ip/link_iptnl.c       | 12 +++++++++++-
>  ip/tunnel.c           | 10 ++++++++++
>  man/man8/ip-link.8.in |  9 +++++----
>  3 files changed, 26 insertions(+), 5 deletions(-)
>
> diff --git a/ip/link_iptnl.c b/ip/link_iptnl.c
> index 8411a6a00a1b..34e4625b4335 100644
> --- a/ip/link_iptnl.c
> +++ b/ip/link_iptnl.c
> @@ -23,6 +23,13 @@
>  #include "ip_common.h"
>  #include "tunnel.h"
>
> +/* This should be in ip.h but it might not be.
> + * What to do?
> + */
> +#ifndef IPPROTO_MPLS
> +#define IPPROTO_MPLS 137 /* RFC 4023 */
> +#endif
> +

This is defined in iproute2's copy of linux/in.h


>  static void print_usage(FILE *f, int sit)
>  {
>  	fprintf(f, "Usage: ip link { add | set | change | replace | del } NAME\n");
> @@ -33,7 +40,7 @@ static void print_usage(FILE *f, int sit)
>  	fprintf(f, "          [ encap-sport PORT ] [ encap-dport PORT ]\n");
>  	fprintf(f, "          [ [no]encap-csum ] [ [no]encap-csum6 ] [ [no]encap-remcsum ]\n");
>  	if (sit) {
> -		fprintf(f, "          [ mode { ip6ip | ipip | any } ]\n");
> +		fprintf(f, "          [ mode { ip6ip | ipip | mplsip | any } ]\n");
>  		fprintf(f, "          [ isatap ]\n");
>  	}
>  	fprintf(f, "\n");
> @@ -222,6 +229,9 @@ get_failed:
>  				 strcmp(*argv, "ipip") == 0 ||
>  				 strcmp(*argv, "ip4ip4") == 0)
>  				proto = IPPROTO_IPIP;
> +			else if (strcmp(*argv, "mpls/ipv4") == 0 ||
> +				   strcmp(*argv, "mplsip") == 0)
> +				proto = IPPROTO_MPLS;
>  			else if (strcmp(*argv, "any/ipv4") == 0 ||
>  				 strcmp(*argv, "any") == 0)
>  				proto = 0;
> diff --git a/ip/tunnel.c b/ip/tunnel.c
> index 7956d71aa733..760fa18a5be6 100644
> --- a/ip/tunnel.c
> +++ b/ip/tunnel.c
> @@ -37,6 +37,13 @@
>  #include "utils.h"
>  #include "tunnel.h"
>
> +/* This should be in ip.h but it might not be.
> + * What to do?
> + */
> +#ifndef IPPROTO_MPLS
> +#define IPPROTO_MPLS 137 /* RFC 4023 */
> +#endif

ditto

David
