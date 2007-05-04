From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] AF_RXRPC: Sort out MTU handling
Date: Fri, 04 May 2007 12:42:25 -0700 (PDT)
Message-ID: <20070504.124225.111205875.davem@davemloft.net>
References: <20070504145647.19125.99441.stgit@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: dhowells@redhat.com
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20070504145647.19125.99441.stgit@warthog.cambridge.redhat.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Howells <dhowells@redhat.com>
Date: Fri, 04 May 2007 15:56:47 +0100

> Sort out the MTU determination and handling in AF_RXRPC:
> 
>  (1) If it's present, parse the additional information supplied by the peer at
>      the end of the ACK packet (struct ackinfo) to determine the MTU sizes
>      that peer is willing to support.
> 
>  (2) Initialise the MTU size to that peer from the kernel's routing records.
> 
>  (3) Send ACKs rather than ACKALLs as the former carry the additional info,
>      and the latter do not.
> 
>  (4) Declare the interface MTU size in outgoing ACKs as a maximum amount of
>      data that can be stuffed into an RxRPC packet without it having to be
>      fragmented to come in this computer's NIC.
> 
>  (5) If sendmsg() is given MSG_MORE then it should allocate an skb of the
>      maximum size rather than one just big enough for the data it's got left
>      to process on the theory that there is more data to come that it can
>      append to that packet.
> 
>      This means, for example, that if AFS does a large StoreData op, all the
>      packets barring the last will be filled to the maximum unfragmented size.
> 
> Signed-off-by: David Howells <dhowells@redhat.com>

Applied, thanks.

