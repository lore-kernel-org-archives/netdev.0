From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET_DMA: free skbs periodically
Date: Sat, 20 Mar 2010 14:29:20 -0700 (PDT)
Message-ID: <20100320.142920.242147630.davem@davemloft.net>
References: <1268752964-4397-1-git-send-email-steve@digidescorp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	linux-kernel@vger.kernel.org
To: steve@digidescorp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46934
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751231Ab0CTV25 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Mar 2010 17:28:57 -0400
In-Reply-To: <1268752964-4397-1-git-send-email-steve@digidescorp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Steven J. Magnani" <steve@digidescorp.com>
Date: Tue, 16 Mar 2010 10:22:44 -0500

> Under NET_DMA, data transfer can grind to a halt when userland issues a
> large read on a socket with a high RCVLOWAT (i.e., 512 KB for both).
> This appears to be because the NET_DMA design queues up lots of memcpy 
> operations, but doesn't issue or wait for them (and thus free the 
> associated skbs) until it is time for tcp_recvmesg() to return. 
> The socket hangs when its TCP window goes to zero before enough data is 
> available to satisfy the read.
> 
> Periodically issue asynchronous memcpy operations, and free skbs for ones 
> that have completed, to prevent sockets from going into zero-window mode.
> 
> Signed-off-by: Steven J. Magnani <steve@digidescorp.com>

Applied, thanks for fixing this bug Steven.
