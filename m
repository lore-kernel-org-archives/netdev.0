From: David Miller <davem@davemloft.net>
Subject: Re: Gianfar: RX Recycle skb->len error
Date: Mon, 22 Mar 2010 20:30:53 -0700 (PDT)
Message-ID: <20100322.203053.37576243.davem@davemloft.net>
References: <20100321.214642.67901344.davem@davemloft.net>
	<20100322172446.GA32758@oksana.dev.rtsoft.ru>
	<A6A1774AFD79E346AE6D49A33CB294530DC19F18@EX-BE-017-SFO.shared.themessagecenter.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: avorontsov@ru.mvista.com, netdev@vger.kernel.org,
	Sandeep.Kumar@freescale.com
To: ben@bigfootnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47219
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754182Ab0CWDaa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Mar 2010 23:30:30 -0400
In-Reply-To: <A6A1774AFD79E346AE6D49A33CB294530DC19F18@EX-BE-017-SFO.shared.themessagecenter.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Ben Menchaca (ben@bigfootnetworks.com)" <ben@bigfootnetworks.com>
Date: Mon, 22 Mar 2010 14:10:48 -0700

> 	It's yucky, but skb_reserve(skb, -alignamount) works,

I have no problem with people using that.

> 	It seems in both these cases for gianfar, the amount of the
> 	alignment is not immediately available to the code the
> 	recognizes that the skb_reset_reserved() is required.  A bit
> 	larger rework appears to be needed.

There's no need to make this so complicated.  Just remember the
value and then refer to it later, when needed.

struct gianfar_skb_cb {
       int	alignamount;
};

#define GIANFAR_CB(skb) ((struct gianfar_skb_cb *)((skb)->cb))

...
	GIANFAR_CB(skb)->alignamount = alignamount;
...

		skb_reserve(skb, -GIANFAR_CB(skb)->alignamount);
