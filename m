From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2.6 PKT_SCHED]: Fix overflow on 64bit in times reported
 to userspace by tc actions
Date: Thu, 11 Nov 2004 15:03:14 -0800
Message-ID: <20041111150314.576ce699.davem@davemloft.net>
References: <41908D1D.50405@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <41908D1D.50405@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 09 Nov 2004 10:25:49 +0100
Patrick McHardy <kaber@trash.net> wrote:

> This patch fixes on overflow in tc actions times reported to
> userspace on 64 bit architectures. struct tcf_t only contains
> 32-bit timestamps, but they are initialized to jiffies. When
> jiffies is larger than 2^32-1 only the low 32 bit are saved,
> and the diff between jiffies and the current timestamp becomes
> very large. This happens immediately after boottime since jiffies
> is initialized to 2^32-300. It was invisible until now because
> only the lower 32bit were reported to userspace, but with the
> USER_HZ conversion the reported times start somewhere around
> 4294967s.
> 
> This patch extends the timestamps to 64bit. It breaks userspace
> compatibility for actions, but considering that most of this is
> not even in iproute yet this should be acceptable.

I agree, and since Jamal also ACK'd it, I've applied
this patch.

Thanks.
