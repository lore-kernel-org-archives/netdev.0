From: Jie Yang <Jie.Yang@Atheros.com>
Subject: RE: TSOv6 broken in atl1e
Date: Tue, 1 Dec 2009 13:17:11 +0800
Message-ID: <72981EBCFD196144B7C6999B9FC34A9A494C6DA471@SHEXMB-01.global.atheros.com>
References: <1259637579.3709.196.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "558426@bugs.debian.org" <558426@bugs.debian.org>,
	netdev <netdev@vger.kernel.org>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 175.210.DSNET ([203.110.175.210]:8357 "EHLO mail.atheros.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750811AbZLAFWi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2009 00:22:38 -0500
In-Reply-To: <1259637579.3709.196.camel@localhost>
Content-Language: zh-CN
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday, December 01, 2009 11:20 AM
Ben Hutchings <ben@decadent.org.uk>
>
> I received a bug report <http://bugs.debian.org/558426> that
> shows atl1e corrupting IPv6 packets.  I have reproduced this
> on an Eee PC 901 and found that it is linked to TSO.  The
> most obvious thing wrong with the driver code is that it
> calculates the super-packet length incorrectly.
> However, fixing that:
>
> --- a/drivers/net/atl1e/atl1e_main.c
> +++ b/drivers/net/atl1e/atl1e_main.c
> @@ -1667,6 +1667,7 @@ static int atl1e_tso_csum(struct
> atl1e_adapter *adapter,
>
>               if (offload_type & SKB_GSO_TCPV6) {
>                       real_len = (((unsigned char
> *)ipv6_hdr(skb) - skb->data)
> +                                     + sizeof(struct ipv6hdr)
>                                       +
> ntohs(ipv6_hdr(skb)->payload_len));
>                       if (real_len < skb->len)
>                               pskb_trim(skb, real_len);
> --- END ---
>
> does not solve the problem.  Presumably this function is not
> constructing correct DMA descriptors for TSOv6.
>
> Please fix this, or I will submit a patch to remove this
> feature from the driver.
>
> Ben.
>
ok, I will try to reproduce it.

Best wishes
jie
