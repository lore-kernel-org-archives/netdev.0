From: David Miller <davem@davemloft.net>
Subject: Re: Socket buffer sizes with autotuning
Date: Wed, 07 May 2008 14:20:13 -0700 (PDT)
Message-ID: <20080507.142013.219220793.davem@davemloft.net>
References: <d1c2719f0805062057q62decefcg7c3de96271c4b26d@mail.gmail.com>
	<20080506.212829.213490532.davem@davemloft.net>
	<d1c2719f0805071154t20004e9drecd3d9b7b9b3470c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hkchu@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56173
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752370AbYEGVUT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2008 17:20:19 -0400
In-Reply-To: <d1c2719f0805071154t20004e9drecd3d9b7b9b3470c@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Jerry Chu" <hkchu@google.com>
Date: Wed, 7 May 2008 11:54:01 -0700

> This is one of many things about skb that I still don't completely understand.
> Why in tcp_transmit_skb() we'll have to pskb_copy() if skb_cloned()?

The other clone holder owns the packet header area.  All packets on
the retransmit queue of TCP are headerless.  The call sites down
into the device add the headers.

Therefore we cannot have two paths modifying the headers at the same
time.

> Can't we clone a skb mulitple times? Is it due to some special optimization
> from skb->fclone stuff... that imposes this restriction?

No, it has nothing to do with fclone.  It has to do with what instance
owns the packet header area in front of the user's TCP data.
