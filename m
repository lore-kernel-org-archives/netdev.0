From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] packet: bail out of packet_snd() if L2 header
 creation fails
Date: Sun, 11 Jan 2015 21:54:27 -0500 (EST)
Message-ID: <20150111.215427.2061918421162909520.davem@davemloft.net>
References: <1420999276-28225-1-git-send-email-cj@linux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: willemb@google.com, edumazet@google.com, dborkman@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: cj@linux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1420999276-28225-1-git-send-email-cj@linux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christoph Jaeger <cj@linux.com>
Date: Sun, 11 Jan 2015 13:01:16 -0500

> Due to a misplaced parenthesis, the expression
> 
>   (unlikely(offset) < 0),
> 
> which expands to
> 
>   (__builtin_expect(!!(offset), 0) < 0),
> 
> never evaluates to true. Therefore, when sending packets with
> PF_PACKET/SOCK_DGRAM, packet_snd() does not abort as intended
> if the creation of the layer 2 header fails.
> 
> Spotted by Coverity - CID 1259975 ("Operands don't affect result").
> 
> Fixes: 9c7077622dd9 ("packet: make packet_snd fail on len smaller than l2 header")
> Signed-off-by: Christoph Jaeger <cj@linux.com>

Applied, thank you.
