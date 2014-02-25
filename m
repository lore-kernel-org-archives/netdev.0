From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] ipv6: log src and dst along with "udp checksum
 is 0"
Date: Tue, 25 Feb 2014 11:44:38 -0800
Message-ID: <1393357478.8716.35.camel@joe-AO722>
References: <1393356845-15287-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0210.hostedemail.com ([216.40.44.210]:48283 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752522AbaBYTol (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Feb 2014 14:44:41 -0500
In-Reply-To: <1393356845-15287-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-02-25 at 20:34 +0100, Bj=F8rn Mork wrote:
> These info messages are rather pointless without any means to identif=
y
> the source of the bogus packets.  Logging the src and dst addresses
> may help a bit.
[]
> diff --git a/net/ipv6/ip6_checksum.c b/net/ipv6/ip6_checksum.c
[]
> @@ -79,7 +79,8 @@ int udp6_csum_init(struct sk_buff *skb, struct udph=
dr *uh, int proto)
>  		/* RFC 2460 section 8.1 says that we SHOULD log
>  		   this error. Well, it is reasonable.
>  		 */
> -		LIMIT_NETDEBUG(KERN_INFO "IPv6: udp checksum is 0\n");
> +		LIMIT_NETDEBUG(KERN_INFO "IPv6: udp checksum is 0 [%pI6c > %pI6c]\=
n",
> +			       &ipv6_hdr(skb)->saddr, &ipv6_hdr(skb)->daddr);

Might be useful to mirror the ipv4 form and add port #'s too.
