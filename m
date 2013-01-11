From: Romain KUNTZ <r.kuntz@ipflavors.com>
Subject: Re: [PATCH 2/2] ipv6: fix packet corruption when Dest/RT2 options are used
Date: Fri, 11 Jan 2013 08:27:32 +0100
Message-ID: <25F004CB-8D03-4280-BDBD-48C149E7321F@ipflavors.com>
References: <0CC79564-4AF2-42F9-8D06-1BCC912A1AF7@ipflavors.com> <C7895CAA-0AF7-4EED-B9E7-9D8E4A21442B@ipflavors.com>
Mime-Version: 1.0 (Mac OS X Mail 6.2 \(1499\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: yoshfuji@linux-ipv6.org, davem@davemloft.net,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Romain KUNTZ <r.kuntz@ipflavors.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:51310 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752957Ab3AKH1f convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2013 02:27:35 -0500
Received: by mail-wg0-f46.google.com with SMTP id dr13so655743wgb.25
        for <netdev@vger.kernel.org>; Thu, 10 Jan 2013 23:27:34 -0800 (PST)
In-Reply-To: <C7895CAA-0AF7-4EED-B9E7-9D8E4A21442B@ipflavors.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Jan 5, 2013, at 17:19 , Romain KUNTZ <r.kuntz@ipflavors.com> wrote:
> Commit 299b0767 (ipv6: Fix IPsec slowpath fragmentation problem)
> has introduced a bug that provokes corrupted packets when Destination
> Options or Routing Header Type 2 are used (such as with Mobile IPv6):
> rt->rt6i_nfheader_len should be substracted to rt->dst.header_len,
> and not to exthdrlen.
> 
> This patch reverts to the original and correct behavior. Successfully
> tested with and without IPsec activated for MH packets.
> 
> Signed-off-by: Romain Kuntz <r.kuntz@ipflavors.com>
> Acked-by: Steffen Klassert <steffen.klassert@secunet.com>
> ---
> net/ipv6/ip6_output.c |    4 ++--
> 1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
> index 5552d13..0c7c03d 100644
> --- a/net/ipv6/ip6_output.c
> +++ b/net/ipv6/ip6_output.c
> @@ -1213,10 +1213,10 @@ int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to,
> 		if (dst_allfrag(rt->dst.path))
> 			cork->flags |= IPCORK_ALLFRAG;
> 		cork->length = 0;
> -		exthdrlen = (opt ? opt->opt_flen : 0) - rt->rt6i_nfheader_len;
> +		exthdrlen = (opt ? opt->opt_flen : 0);
> 		length += exthdrlen;
> 		transhdrlen += exthdrlen;
> -		dst_exthdrlen = rt->dst.header_len;
> +		dst_exthdrlen = rt->dst.header_len - rt->rt6i_nfheader_len;
> 	} else {
> 		rt = (struct rt6_info *)cork->dst;
> 		fl6 = &inet->cork.fl.u.ip6;
> -- 
> 1.7.2.5

Resending this one adding the 'Acked-by: Steffen Klassert'.

Romain