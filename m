From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET_DMA: free skbs periodically
Date: Thu, 18 Mar 2010 20:36:44 -0700 (PDT)
Message-ID: <20100318.203644.102533317.davem@davemloft.net>
References: <1268752964-4397-1-git-send-email-steve@digidescorp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	linux-kernel@vger.kernel.org
To: steve@digidescorp.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1268752964-4397-1-git-send-email-steve@digidescorp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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

Can one of the NET DMA folks review this.

It's a pretty fundamental problem with how this stuff works
it seems.
