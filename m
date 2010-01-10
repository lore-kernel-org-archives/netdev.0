From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH net-2.6 resent] af_packet: Don't use skb after
 dev_queue_xmit()
Date: Sun, 10 Jan 2010 23:21:29 +0100
Message-ID: <20100110222129.GA3606@del.dom.local>
References: <20100109123827.GB4386@del.dom.local>
 <20100110.135135.237364018.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mbreuer@majjas.com, shemminger@vyatta.com,
	akpm@linux-foundation.org, flyboy@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f215.google.com ([209.85.220.215]:58865 "EHLO
	mail-fx0-f215.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754052Ab0AJWVg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jan 2010 17:21:36 -0500
Content-Disposition: inline
In-Reply-To: <20100110.135135.237364018.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 10, 2010 at 01:51:35PM -0800, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Sat, 9 Jan 2010 13:38:27 +0100
> 
> > tpacket_snd() can change and kfree an skb after dev_queue_xmit(),
> > which is illegal.
> > 
> > With debugging by: Stephen Hemminger <shemminger@vyatta.com>
> > 
> > Reported-by: Michael Breuer <mbreuer@majjas.com>
> > Tested-by: Michael Breuer <mbreuer@majjas.com>
> > Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
> > Acked-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> Jarek, if this code path triggers, it will deadlock the
> send ring with your changes.
> 
> We will now leave the ring packet status in the "SENDING" state.
> 
> That's not right.

No, the destructor of this skb, tpacket_destruct_skb(), will clean
this. (Just like for other skbs kfreed during dev_queue_xmit().)

Jarek P.
