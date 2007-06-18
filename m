From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH 1/3] [IPV6]: Restore semantics of Routing Header processing.
Date: Mon, 18 Jun 2007 14:16:29 -0400
Message-ID: <4676CBFD.1040901@hp.com>
References: <20070618.150423.46608800.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, pekkas@netcore.fi, netdev@vger.kernel.org
To: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:59591 "EHLO atlrel6.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760495AbXFRSQg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Jun 2007 14:16:36 -0400
In-Reply-To: <20070618.150423.46608800.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E wrote:
>  					 IPSTATS_MIB_INHDRERRORS);
> @@ -465,6 +440,8 @@ looped_back:
>  		break;
>  #ifdef CONFIG_IPV6_MIP6
>  	case IPV6_SRCRT_TYPE_2:
> +		if (accept_source_route < 0)
> +			goto unknown_rh;
>  		/* Silently discard invalid RTH type 2 */
>  		if (hdr->hdrlen !=3D 2 || hdr->segments_left !=3D 1) {
>  			IP6_INC_STATS_BH(ip6_dst_idev(skb->dst),

Do we really want to do this.  The IPv6 working group is bending over b=
ackwards
in it's attempt to _not_ break MIPv6 while deprecating RH0.  The abilit=
y to "break"
MIPv6 by disable RH2 without disabling the rest of MIP seems a "bad thi=
ng" to me.

-vlad

