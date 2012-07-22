From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: Make "Invalid Stream Identifier" ERROR follows
 SACK when bundling
Date: Sun, 22 Jul 2012 12:45:14 -0700 (PDT)
Message-ID: <20120722.124514.239340989320198501.davem@davemloft.net>
References: <1342677450-21810-1-git-send-email-xufengzhang.main@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevich@gmail.com, sri@us.ibm.com, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: xufengzhang.main@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1342677450-21810-1-git-send-email-xufengzhang.main@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: <xufengzhang.main@gmail.com>
Date: Thu, 19 Jul 2012 13:57:30 +0800

> When "Invalid Stream Identifier" ERROR happens after process the
> received DATA chunks, this ERROR chunk is enqueued into outqueue
> before SACK chunk, so when bundling ERROR chunk with SACK chunk,
> the ERROR chunk is always placed first in the packet because of
> the chunk's position in the outqueue.
> This violates sctp specification:
>     RFC 4960 6.5. Stream Identifier and Stream Sequence Number
>     ...The endpoint may bundle the ERROR chunk in the same
>     packet as the SACK as long as the ERROR follows the SACK.
> So we must place SACK first when bundling "Invalid Stream Identifier"
> ERROR and SACK in one packet.
> Although we can do that by enqueue SACK chunk into outqueue before
> ERROR chunk, it will violate the side-effect interpreter processing.
> It's easy to do this job when dequeue chunks from the outqueue,
> by this way, we introduce a flag 'has_isi_err' which indicate
> whether or not the "Invalid Stream Identifier" ERROR happens.
> 
> Signed-off-by: Xufeng Zhang <xufeng.zhang@windriver.com>

Can some SCTP experts please review this?
