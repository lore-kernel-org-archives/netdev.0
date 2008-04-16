From: David Miller <davem@davemloft.net>
Subject: Re: TG3 network data corruption regression 2.6.24/2.6.23.4
Date: Tue, 15 Apr 2008 20:31:08 -0700 (PDT)
Message-ID: <20080415.203108.55491723.davem@davemloft.net>
References: <47BC44E2.9060301@cybernetics.com>
	<20080415001207.GA11852@localdomain>
	<4804CC2F.6030403@cybernetics.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mcarlson@broadcom.com, herbert@gondor.apana.org.au,
	mchan@broadcom.com, netdev@vger.kernel.org, gregkh@suse.de,
	linux-kernel@vger.kernel.org
To: tonyb@cybernetics.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760502AbYDPDbY@vger.kernel.org>
In-Reply-To: <4804CC2F.6030403@cybernetics.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tony Battersby <tonyb@cybernetics.com>
Date: Tue, 15 Apr 2008 11:39:27 -0400

> Thanks, your patch fixes the problem (tested on 2.6.24.4).  However, I
> had to change "(skb->mac_header & 3)" in your patch to "((long)
> skb->mac_header & 3)" since mac_header is a pointer rather than an int
> on 32-bit systems.
> 
> Tested-by: Tony Battersby <tonyb@cybernetics.com>

Thanks for testing.

Matt, skb->mac_header is either a pointer or an integer offset
depending upon whether we are building 32-bit or 64-bit.

Testing skb->mac_header is therefore wrong, because it's an
offset from a pointer in the 64-bit case and therefore it's
alignment does not indicate correctly the actual final alignment
of skb->head + skb->max_header.

Therefore you should test skb_mac_header(skb) and cast it with
(unsigned long).

Please respin this fix with that correction so I can apply it
and get this bug fixed, thanks!
