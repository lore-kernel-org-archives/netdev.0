From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [Patch iproute2] vxlan: use 8472 as default dst port
Date: Wed, 15 May 2013 07:32:28 -0400
Message-ID: <OFA8084FAB.8443890D-ON85257B6C.003F1FAB-85257B6C.003F65F2@us.ibm.com>
References: <1368616270-5775-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Cong Wang <amwang@redhat.com>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:39026 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757295Ab3EOLdN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 May 2013 07:33:13 -0400
Received: from /spool/local
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Wed, 15 May 2013 05:33:13 -0600
In-Reply-To: <1368616270-5775-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netdev-owner@vger.kernel.org wrote on 05/15/2013 07:11:10 AM:

> From: Cong Wang <amwang@redhat.com>

> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Signed-off-by: Cong Wang <amwang@redhat.com>
> 
> ---
> diff --git a/ip/iplink_vxlan.c b/ip/iplink_vxlan.c
> index 2d93ee2..a0c90b3 100644
> --- a/ip/iplink_vxlan.c
> +++ b/ip/iplink_vxlan.c
> @@ -53,7 +53,7 @@ static int vxlan_parse_opt(struct link_util *lu, 
> int argc, char **argv,
>     __u8 noage = 0;
>     __u32 age = 0;
>     __u32 maxaddr = 0;
> -   __u16 dstport = 4789;
> +   __u16 dstport = 8472;

I think this should be "0"; then it will use the kernel port,
whatever it is.

> @@ -188,8 +188,7 @@ static int vxlan_parse_opt(struct link_util *lu,
> int argc, char **argv,
>     if (range.low || range.high)
>        addattr_l(n, 1024, IFLA_VXLAN_PORT_RANGE,
>             &range, sizeof(range));
> -   if (dstport)
> -      addattr16(n, 1024, IFLA_VXLAN_PORT, htons(dstport));
> +   addattr16(n, 1024, IFLA_VXLAN_PORT, htons(dstport));

        ...and these lines should be left alone. If not specified,
it won't pass an alternate port and will use the kernel default.

                                                +-DLS
