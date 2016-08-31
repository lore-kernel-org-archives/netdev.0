From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] softirq: let ksoftirqd do its job
Date: Wed, 31 Aug 2016 16:11:06 -0700
Message-ID: <1472685066.14381.380.camel@edumazet-glaptop3.roam.corp.google.com>
References: <4f1c4b38528762619fff1fa963de8971006c1234.1472460085.git.pabeni@redhat.com>
         <20160831100854.23dad2d8@redhat.com>
         <1472650472.14381.317.camel@edumazet-glaptop3.roam.corp.google.com>
         <1472650688.32433.115.camel@redhat.com>
         <1472652643.14381.320.camel@edumazet-glaptop3.roam.corp.google.com>
         <20160831164216.2901190c@redhat.com>
         <1472661956.14381.335.camel@edumazet-glaptop3.roam.corp.google.com>
         <1472665349.14381.356.camel@edumazet-glaptop3.roam.corp.google.com>
         <20160831214043.2f44cf08@redhat.com>
         <1472676150.14381.363.camel@edumazet-glaptop3.roam.corp.google.com>
         <20160831235116.33b1946b@redhat.com>
         <1472682450.14381.364.camel@edumazet-glaptop3.roam.corp.google.com>
         <3567b503-8b3e-5a3f-580a-f99fd28cf77e@hpe.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <jbrouer@redhat.com>,
        Peter Zijlstra <peterz@infradead.org>,
        David Miller <davem@davemloft.net>,
        Rik van Riel <riel@redhat.com>,
        Paolo Abeni <pabeni@redhat.com>,
        Hannes Frederic Sowa <hannes@redhat.com>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>, Jonathan Corbet <corbet@lwn.net>
To: Rick Jones <rick.jones2@hpe.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <3567b503-8b3e-5a3f-580a-f99fd28cf77e@hpe.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2016-08-31 at 15:47 -0700, Rick Jones wrote:
> With regard to drops, are both of you sure you're using the same socket 
> buffer sizes?

Does it really matter ?

I used the standard /proc/sys/net/core/rmem_default, but under flood
receive queue is almost always full, even if you make it bigger.

By varying its size, you only make batches bigger and number of context
switches should be lower, if only two threads are competing for the cpu.

Exact 'optimal' size would depend on various factors, depending on
application and platform constraints.

> 
> In the meantime, is anything interesting happening with TCP_RR or 
> TCP_STREAM?

TCP_RR is driven by the network latency, we do not drop packets in the
socket itself.

TC_STREAM is normally paced by the ability of the receiver to send ACK
packets. TCP has this auto regulating mode, unless the sender violates
the RFC(s).

If your question is :

What happens if thousands of threads on the host want the cpu, and
ksoftirqd gets not enough cycles by virtue of being a normal thread ?

Then, you are back to typical provisioning problems, and normally people
play with priorities and containers/cgroups, and/or various techniques
like RPS/RFS

(You can change ksoftirqd priority if you like)
