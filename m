From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH v2] net/sched: add ACT_CSUM action to update packets
 checksums
Date: Wed, 18 Aug 2010 06:52:10 -0400
Message-ID: <1282128730.23601.11.camel@bigi>
References: <20100817235952.GB24125@n7mm.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Gr=E9goire?= Baron <baronchon@n7mm.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:44687 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751902Ab0HRKwO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Aug 2010 06:52:14 -0400
Received: by qyk33 with SMTP id 33so456675qyk.19
        for <netdev@vger.kernel.org>; Wed, 18 Aug 2010 03:52:13 -0700 (PDT)
In-Reply-To: <20100817235952.GB24125@n7mm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-08-18 at 01:59 +0200, Gr=C3=A9goire Baron wrote:


> +static int tcf_csum_ipv4_icmp(struct sk_buff *skb,
> +			      unsigned int ihl, unsigned int ipl)
> +{
> +	struct icmphdr *icmph;
> +
> +	icmph =3D tcf_csum_skb_nextlayer(skb, ihl, ipl, sizeof(*icmph));
> +	if (icmph =3D=3D NULL)
> +		goto fail;
                  ^^^^^^^^^^^
> +	icmph->checksum =3D 0;
> +	skb->csum =3D csum_partial(icmph, ipl - ihl, 0);
> +	icmph->checksum =3D csum_fold(skb->csum);
> +
> +	skb->ip_summed =3D CHECKSUM_NONE;
> +
> +	return 1;
> +
> +fail:
> +	return 0;
> +}
> +

I think you missed one of my earlier comments:
Do you really need this goto? You should just "return 0" instead of
"goto fail"
Same with many other similar places where the "fail:" just simply
returns 0 such as igmp, ipv6_icmp, ipv4_udp, etc

BTW, i still think there may be a clever way to unify things - but we
can leave that for another day;-> If you fix the above please add
my Acked-by.

cheers,
jamal

