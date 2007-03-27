From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] [SK_BUFF]: Introduce
 skb_copy_from_linear_data{_offset}
Date: Tue, 27 Mar 2007 14:07:49 -0700 (PDT)
Message-ID: <20070327.140749.106434705.davem@davemloft.net>
References: <20070327194148.GC20303@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: acme@ghostprotocols.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55444
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965417AbXC0VHu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2007 17:07:50 -0400
In-Reply-To: <20070327194148.GC20303@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Tue, 27 Mar 2007 16:41:48 -0300

> +static inline void skb_move_linear_data(const struct sk_buff *skb,
> +					const int from_offset,
> +					const int to_offset,
> +					const unsigned int len)
> +{
> +	memcpy(skb->data + to_offset, skb->data + from_offset, len);
> +}
> +

What do you intend to use this for?  There are no users in
your patch, and I'd be fearful of overlapping cases (which
ought to be common for anything using this) which therefore
would require use of memmove() instead of memcpy().

How about we just leave out interfaces until we have a use
case?
