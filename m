From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH iproute2 3/3] ip/ip6tunnel: fix update of tclass and
 flowlabel
Date: Fri, 16 Nov 2012 08:16:13 -0800
Message-ID: <20121116081613.75cbb7b0@nehalam.linuxnetplumber.net>
References: <1352906966-12932-1-git-send-email-nicolas.dichtel@6wind.com>
	<1352906966-12932-3-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:45809 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752598Ab2KPQRU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Nov 2012 11:17:20 -0500
In-Reply-To: <1352906966-12932-3-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 14 Nov 2012 16:29:26 +0100
Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:

> When tclass or flowlabel field were updated, we only performed an OR with the
> new value. For example, it was not possible to reset tclass:
>   ip -6 tunnel change ip6tnl2 tclass 0
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> ---
>  ip/ip6tunnel.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/ip/ip6tunnel.c b/ip/ip6tunnel.c
> index 7aaac61..fcc9f33 100644
> --- a/ip/ip6tunnel.c
> +++ b/ip/ip6tunnel.c
> @@ -173,6 +173,7 @@ static int parse_args(int argc, char **argv, int cmd, struct ip6_tnl_parm *p)
>  			   matches(*argv, "dsfield") == 0) {
>  			__u8 uval;
>  			NEXT_ARG();
> +			p->flowinfo &= ~IP6_FLOWINFO_TCLASS;
>  			if (strcmp(*argv, "inherit") == 0)
>  				p->flags |= IP6_TNL_F_USE_ORIG_TCLASS;
>  			else {
> @@ -185,6 +186,7 @@ static int parse_args(int argc, char **argv, int cmd, struct ip6_tnl_parm *p)
>  			   strcmp(*argv, "fl") == 0) {
>  			__u32 uval;
>  			NEXT_ARG();
> +			p->flowinfo &= ~IP6_FLOWINFO_FLOWLABEL;
>  			if (strcmp(*argv, "inherit") == 0)
>  				p->flags |= IP6_TNL_F_USE_ORIG_FLOWLABEL;
>  			else {

All applied thanks.
