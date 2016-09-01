From: Hannes Frederic Sowa <hannes@redhat.com>
Subject: Re: [PATCH] softirq: let ksoftirqd do its job
Date: Thu, 1 Sep 2016 14:01:05 +0200
Message-ID: <dd87ffeb-2cf0-a2be-895b-22837b75fb4c@redhat.com>
References: <4f1c4b38528762619fff1fa963de8971006c1234.1472460085.git.pabeni@redhat.com>
 <20160831100854.23dad2d8@redhat.com>
 <1472650472.14381.317.camel@edumazet-glaptop3.roam.corp.google.com>
 <1472650688.32433.115.camel@redhat.com>
 <1472652643.14381.320.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160831164216.2901190c@redhat.com>
 <1472661956.14381.335.camel@edumazet-glaptop3.roam.corp.google.com>
 <1472665349.14381.356.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Rik van Riel <riel@redhat.com>, Paolo Abeni <pabeni@redhat.com>,
        Jesper Dangaard Brouer <jbrouer@redhat.com>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>, Jonathan Corbet <corbet@lwn.net>
To: Eric Dumazet <eric.dumazet@gmail.com>,
        Peter Zijlstra <peterz@infradead.org>,
        David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1472665349.14381.356.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 31.08.2016 19:42, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> A while back, Paolo and Hannes sent an RFC patch adding threaded-able
> napi poll loop support : (https://patchwork.ozlabs.org/patch/620657/) 
> 
> The problem seems to be that softirqs are very aggressive and are often
> handled by the current process, even if we are under stress and that
> ksoftirqd was scheduled, so that innocent threads would have more chance
> to make progress.
> 
> This patch makes sure that if ksoftirq is running, we let it
> perform the softirq work.
> 
> Jonathan Corbet summarized the issue in https://lwn.net/Articles/687617/
> 
> Tested:
> 
>  - NIC receiving traffic handled by CPU 0
>  - UDP receiver running on CPU 0, using a single UDP socket.
>  - Incoming flood of UDP packets targeting the UDP socket.
> 
> Before the patch, the UDP receiver could almost never get cpu cycles and
> could only receive ~2,000 packets per second.
> 
> After the patch, cpu cycles are split 50/50 between user application and
> ksoftirqd/0, and we can effectively read ~900,000 packets per second,
> a huge improvement in DOS situation. (Note that more packets are now
> dropped by the NIC itself, since the BH handlers get less cpu cycles to
> drain RX ring buffer)
> 
> Since the load runs in well identified threads context, an admin can
> more easily tune process scheduling parameters if needed.
> 
> Reported-by: Paolo Abeni <pabeni@redhat.com>
> Reported-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: David Miller <davem@davemloft.net
> Cc: Jesper Dangaard Brouer <jbrouer@redhat.com>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Rik van Riel <riel@redhat.com>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Thanks,
Hannes
