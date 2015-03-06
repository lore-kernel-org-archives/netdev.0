From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next] mpls: Properly validate RTA_VIA payload length
Date: Fri, 06 Mar 2015 14:06:39 -0600
Message-ID: <87vbid99gw.fsf@x220.int.ebiederm.org>
References: <1425638820-19990-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Robert Shearman <rshearma@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:37935 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755982AbbCFUKQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2015 15:10:16 -0500
In-Reply-To: <1425638820-19990-1-git-send-email-rshearma@brocade.com> (Robert
	Shearman's message of "Fri, 6 Mar 2015 10:47:00 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Robert Shearman <rshearma@brocade.com> writes:

> If the nla length is less than 2 then the nla data could be accessed
> beyond the accessible bounds. So ensure that the nla is big enough to
> at least read the via_family before doing so. Replace magic value of
> 2.
>

Acked-by: "Eric W. Biederman" <ebiederm@xmission.com>
> Fixes: 03c0566542f4 ("mpls: Basic support for adding and removing routes")
> Cc: Eric W. Biederman <ebiederm@xmission.com>
> Signed-off-by: Robert Shearman <rshearma@brocade.com>
> ---
>  net/mpls/af_mpls.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
>
> diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
> index 23e51d1..4ce39f6 100644
> --- a/net/mpls/af_mpls.c
> +++ b/net/mpls/af_mpls.c
> @@ -585,8 +585,11 @@ static int rtm_to_route_config(struct sk_buff *skb,  struct nlmsghdr *nlh,
>  		case RTA_VIA:
>  		{
>  			struct rtvia *via = nla_data(nla);
> +			if (nla_len(nla) < offsetof(struct rtvia, rtvia_addr))
> +				goto errout;
>  			cfg->rc_via_family = via->rtvia_family;
> -			cfg->rc_via_alen   = nla_len(nla) - 2;
> +			cfg->rc_via_alen   = nla_len(nla) -
> +				offsetof(struct rtvia, rtvia_addr);
>  			if (cfg->rc_via_alen > MAX_VIA_ALEN)
>  				goto errout;
