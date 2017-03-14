From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH] sock: add SO_RCVQUEUE_SIZE getsockopt
Date: Mon, 13 Mar 2017 18:31:27 -0700
Message-ID: <1489455087.28631.107.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1489420786-19547-1-git-send-email-johunt@akamai.com>
         <CANn89iJ21dhirFW2OdNqHWfOgq-EieVMm5ou9pZ7g2oUz=+bfA@mail.gmail.com>
         <522a2e2d-c288-7019-3f12-2b624d6aa921@akamai.com>
         <20170313.123933.1813218797817423920.davem@davemloft.net>
         <9f775c33-01f4-fbd8-4d4d-4ca67f0f6d3b@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, edumazet@google.com,
        arnd@arndb.de, soheil@google.com, willemb@google.com,
        pabeni@redhat.com, linux-arch@vger.kernel.org,
        netdev@vger.kernel.org
To: Josh Hunt <johunt@akamai.com>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <9f775c33-01f4-fbd8-4d4d-4ca67f0f6d3b@akamai.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2017-03-13 at 18:34 -0500, Josh Hunt wrote:

> In this particular case they really do want to know total # of bytes in 
> the receive queue, not the data bytes they can consume from an 
> application pov. The kernel currently only exposes this value through 
> netlink or /proc/net/udp from what I saw.
> 
> I believe Eric's suggestion in his previous mail was to export all of 
> these meminfo metrics via a single socket option call similar to how its 
> done in netlink. We could then use that for both call sites.
> 
> I agree that it would be useful to also have the data you and Eric are 
> suggesting exposed somewhere, the total # of skb->len bytes sitting in 
> the receive queue. I could add that as a second socket option.

Please note that UDP stack does not maintain a per socket sum(skb->len)

Implementing this in a system call would require to lock the receive
queue (blocking BH) and iterating over a potential huge skb list.

Or add a new socket field and add/sub every skb->len of packets
added/removed to/from receive queue.

So I would prefer to not provide this information, this looks quite a
bloat.
