From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH RFC 1/3] ipv4: make flow functions more grepable by
 removing flowi4_init_output
Date: Mon, 13 Jun 2016 16:02:53 -0600
Message-ID: <6b8ad88f-db0b-3a88-197d-ed7278783bfc@cumulusnetworks.com>
References: <1465850858-8559-1-git-send-email-hannes@stressinduktion.org>
 <1465850858-8559-2-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ja@ssi.bg
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:34659 "EHLO
	mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753532AbcFMWCz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 18:02:55 -0400
Received: by mail-pf0-f180.google.com with SMTP id 62so50093321pfd.1
        for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 15:02:55 -0700 (PDT)
In-Reply-To: <1465850858-8559-2-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/13/16 2:47 PM, Hannes Frederic Sowa wrote:
> No functional changes.
>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
>  include/net/flow.h              | 21 ---------------------
>  include/net/route.h             | 33 +++++++++++++++++++++++++++------
>  net/ipv4/inet_connection_sock.c | 41 +++++++++++++++++++++++++++++------------
>  net/ipv4/ip_output.c            | 21 ++++++++++++++-------
>  net/ipv4/ping.c                 | 16 +++++++++++++---
>  net/ipv4/raw.c                  | 20 ++++++++++++++------
>  net/ipv4/route.c                | 38 +++++++++++++++++++++++++++++---------
>  net/ipv4/syncookies.c           | 19 ++++++++++++++-----
>  net/ipv4/udp.c                  | 17 +++++++++++++----
>  9 files changed, 153 insertions(+), 73 deletions(-)
>
> diff --git a/include/net/flow.h b/include/net/flow.h
> index d47ef4bb5423a3..2c8e95b987c98c 100644
> --- a/include/net/flow.h
> +++ b/include/net/flow.h
> @@ -90,27 +90,6 @@ struct flowi4 {
>  #define fl4_gre_key		uli.gre_key
>  } __attribute__((__aligned__(BITS_PER_LONG/8)));
>
> -static inline void flowi4_init_output(struct flowi4 *fl4, int oif,
> -				      __u32 mark, __u8 tos, __u8 scope,
> -				      __u8 proto, __u8 flags,
> -				      __be32 daddr, __be32 saddr,
> -				      __be16 dport, __be16 sport)
> -{
> -	fl4->flowi4_oif = oif;
> -	fl4->flowi4_iif = LOOPBACK_IFINDEX;
> -	fl4->flowi4_mark = mark;
> -	fl4->flowi4_tos = tos;
> -	fl4->flowi4_scope = scope;
> -	fl4->flowi4_proto = proto;
> -	fl4->flowi4_flags = flags;
> -	fl4->flowi4_secid = 0;
> -	fl4->flowi4_tun_key.tun_id = 0;
> -	fl4->daddr = daddr;
> -	fl4->saddr = saddr;
> -	fl4->fl4_dport = dport;
> -	fl4->fl4_sport = sport;
> -}
> -

I found this helper to be unhelpful developing the VRF changes. Really 
obfuscates the initialization of the flow struct. Happy to see it go.

I would like to see more initialization at declaration time as well to 
fix the recurring problem of failing to add an init for new fields. 
Doable for a lot of flow use cases with just some minor refactorings.

Anyways, change LGTM.

Reviewed-by: David Ahern <dsa@cumulusnetworks.com>
