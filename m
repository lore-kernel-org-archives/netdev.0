From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] bridge: fix reporting of IPv6 addresses
Date: Fri, 21 Mar 2014 14:24:00 -0700
Message-ID: <20140321142400.6775cd80@nehalam.linuxnetplumber.net>
References: <1395313570-12545-1-git-send-email-mike.rapoport@ravellosystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Mike Rapoport <mike.rapoport@ravellosystems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:41172 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751009AbaCUVYD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Mar 2014 17:24:03 -0400
Received: by mail-pa0-f49.google.com with SMTP id lj1so2909531pab.36
        for <netdev@vger.kernel.org>; Fri, 21 Mar 2014 14:24:02 -0700 (PDT)
In-Reply-To: <1395313570-12545-1-git-send-email-mike.rapoport@ravellosystems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 20 Mar 2014 13:06:10 +0200
Mike Rapoport <mike.rapoport@ravellosystems.com> wrote:

> Signed-off-by: Mike Rapoport <mike.rapoport@ravellosystems.com>
> ---
>  bridge/fdb.c | 7 ++++++-
>  1 file changed, 6 insertions(+), 1 deletion(-)
> 
> diff --git a/bridge/fdb.c b/bridge/fdb.c
> index e2e53f1..9b720e3 100644
> --- a/bridge/fdb.c
> +++ b/bridge/fdb.c
> @@ -103,8 +103,13 @@ int print_fdb(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
>  
>  	if (tb[NDA_DST]) {
>  		SPRINT_BUF(abuf);
> +		int family = AF_INET;
> +
> +		if (RTA_PAYLOAD(tb[NDA_DST]) == sizeof(struct in6_addr))
> +			family = AF_INET6;
> +
>  		fprintf(fp, "dst %s ",
> -			format_host(AF_INET,
> +			format_host(family,
>  				    RTA_PAYLOAD(tb[NDA_DST]),
>  				    RTA_DATA(tb[NDA_DST]),
>  				    abuf, sizeof(abuf)));

Looks good applied.
