From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: sock: Add option for memory optimized hints.
Date: Fri, 20 May 2016 10:33:14 -0700
Message-ID: <1463765594.18194.301.camel@edumazet-glaptop3.roam.corp.google.com>
References: <573F12F5.7050704@sonymobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: peter enderborg <peter.enderborg@sonymobile.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <573F12F5.7050704@sonymobile.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2016-05-20 at 15:36 +0200, peter enderborg wrote:
> From: Peter Enderborg <peter.enderborg@sonymobile.com>
> 
> When sending data the socket allocates memory for
> payload on a cache or a page alloc. The page alloc
> then might trigger compation that takes long time.
> This can be avoided with smaller chunks. But
> userspace can not know what is the right size for
> the smaller sends. For this we add a SIZEHINT
> getsocketopt where the userspace can get the size
> for send that will fit into one page (order 0) or
> the max for a slab cache allocation.


Very obscure thing if you ask me. Exposing kernel internals like that
seems to work around a more serious issue.

What kind of sockets would ever use KMALLOC_MAX_CACHE_SIZE  allocations
exactly ?

af_unix and tcp are definitely clean.

28d6427109d13b0f447cba5761f88d3548e83605 net: attempt high order allocations in sock_alloc_send_pskb()
e370a7236321773245c5522d8bb299380830d3b2 af_unix: improve STREAM behavior with fragmented memory
eb6a24816b247c0be6b2e97e68933072874bbe54 af_unix: reduce high order page allocations
