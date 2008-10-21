From: David Miller <davem@davemloft.net>
Subject: Re: Regression: Recent networking (qdisc?) patches break
 irda_get_next_speed()
Date: Tue, 21 Oct 2008 16:41:21 -0700 (PDT)
Message-ID: <20081021.164121.257737412.davem@davemloft.net>
References: <48FE1D52.6080903@ceibo.fiec.espol.edu.ec>
	<48FE2F81.9060801@gmail.com>
	<48FE67D4.5060200@ceibo.fiec.espol.edu.ec>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, jarkao2@gmail.com, jussi.kivilinna@mbnet.fi
To: avillaci@ceibo.fiec.espol.edu.ec
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41189
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752069AbYJUXlo convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Oct 2008 19:41:44 -0400
In-Reply-To: <48FE67D4.5060200@ceibo.fiec.espol.edu.ec>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Alex Villac=ED=ADs Lasso <avillaci@ceibo.fiec.espol.edu.ec>
Date: Tue, 21 Oct 2008 18:37:56 -0500

> So then, the bug is that the cb field in the struct sk_buff is being
> interpreted as both a struct qdisc_skb_cb and an struct irda_skb_cb,
> for the same instance of struct sk_buff. I have just started to
> review the suggested patch, but it seems that 'struct qdisc_skb_cb'
> was meant to be aliased against the data for other layers (as
> suggested by the presence of a 'char data[]' field). If so, how come
> only IrDA is affected? How come UDP, TCP, etc. not affected by this?
> On the other hand, if qdisc_skb_cb was not meant to be aliased, then
> the IrDA case was left out while converting the rest of the layers
> so that they will skip over the member 'pkt_len' of the 'struct
> qdisc_skb_cb'.

The SKB control block is not aliased.

Once the packet is given to dev_queue_xmit() the packet scheduler
"owns" the control block of the SKB.

What IRDA is doing is illegal, and breaks in other ways without the
commit in question.

IRDA cannot depend upon the SKB control block not changing across
the dev_queue_xmit() call.
