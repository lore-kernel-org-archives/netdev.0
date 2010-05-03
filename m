From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] ppp_generic: linearise skbs before passing them to
 pppd
Date: Sun, 02 May 2010 23:27:11 -0700 (PDT)
Message-ID: <20100502.232711.256856995.davem@davemloft.net>
References: <4BDB244D.40800@simon.arlott.org.uk>
	<4BDB2469.6020105@simon.arlott.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paulus@samba.org, linux-ppp@vger.kernel.org
To: simon@fire.lp0.eu
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <4BDB2469.6020105@simon.arlott.org.uk>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Simon Arlott <simon@fire.lp0.eu>
Date: Fri, 30 Apr 2010 19:41:45 +0100

> Frequently when using PPPoE with an interface MTU greater than 1500,
> the skb is likely to be non-linear. If the skb needs to be passed to
> pppd then the skb must be linearised first.
> 
> The previous commit fixes an issue with accidentally sending skbs
> to pppd based on an invalid read of the protocol type. When that
> error occurred pppd was reading invalid skb data too.
> 
> Signed-off-by: Simon Arlott <simon@fire.lp0.eu>

Don't propagate stupidity.

The real problem is that ppp_read() can't handle non-linear SKBs, so
fix that instead.  The easiest way to do that is to put a "struct
iovec iov;" on ppp_read()'s stack, fill it in with ther user buffer
pointer and length, then use that to call
skb_copy_datagram_const_iovec().
