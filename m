From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 7/23] [PATCH] [XFRM] STATE: Add a hook to find where to
 be inserted header in outbound.
Date: Sun, 30 Jul 2006 19:31:35 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0607301927050.27032@d.namei>
References: <11541654231584-git-send-email-nakam@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: davem@davemloft.net, yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi,
	vnuorval@tcs.hut.fi, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.sea5.speakeasy.net ([69.17.117.3]:11142 "EHLO
	mail1.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S932481AbWG3Xbk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Jul 2006 19:31:40 -0400
To: Masahide NAKAMURA <nakam@linux-ipv6.org>
In-Reply-To: <11541654231584-git-send-email-nakam@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 29 Jul 2006, Masahide NAKAMURA wrote:

> -		hdr_len = ip6_find_1stfragopt(skb, &prevhdr);
> +		if (x->type->place_find)
> +			hdr_len = x->type->place_find(x, skb, &prevhdr);
> +		else
> +			hdr_len = ip6_find_1stfragopt(skb, &prevhdr);

What about encapsulating this like:

static inline int hdr_offset(...)
{
	if (x->type->place_find)
		return x->type->place_find(x, skb, &prevhdr);
	else
		return ip6_find_1stfragopt(skb, &prevhdr);
}

Maybe also change the naming of ->place_find to ->hdr_offset



- James
-- 
James Morris
<jmorris@namei.org>
