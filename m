From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: ensure message length for raw socket is at least
 sizeof(ipv6hdr)
Date: Tue, 25 Apr 2017 13:55:43 -0400 (EDT)
Message-ID: <20170425.135543.1706004185593424024.davem@davemloft.net>
References: <20170425131827.66498-1-glider@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dvyukov@google.com, kcc@google.com, edumazet@google.com,
        kuznet@ms2.inr.ac.ru, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: glider@google.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170425131827.66498-1-glider@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexander Potapenko <glider@google.com>
Date: Tue, 25 Apr 2017 15:18:27 +0200

> rawv6_send_hdrinc() expects that the buffer copied from the userspace
> contains the IPv6 header, so if too few bytes are copied parts of the
> header may remain uninitialized.
> 
> This bug has been detected with KMSAN.
> 
> Signed-off-by: Alexander Potapenko <glider@google.com>

Hmmm, ipv4 seems to lack this check as well.

I think we need to be careful here and fully understand why KMSAN doesn't
seem to be triggering in the ipv4 case but for ipv6 it is before I apply
this.

Thanks.
