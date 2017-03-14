From: Josh Hunt <johunt@akamai.com>
Subject: Re: [RFC PATCH] sock: add SO_RCVQUEUE_SIZE getsockopt
Date: Tue, 14 Mar 2017 17:11:17 -0500
Message-ID: <7548ab46-6138-9a4e-9465-58f33c9063d7@akamai.com>
References: <522a2e2d-c288-7019-3f12-2b624d6aa921@akamai.com>
 <20170313.123933.1813218797817423920.davem@davemloft.net>
 <9f775c33-01f4-fbd8-4d4d-4ca67f0f6d3b@akamai.com>
 <20170313.171008.1845413549443399902.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, arnd@arndb.de, soheil@google.com,
        willemb@google.com, pabeni@redhat.com, linux-arch@vger.kernel.org,
        netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <20170313.171008.1845413549443399902.davem@davemloft.net>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/13/2017 07:10 PM, David Miller wrote:
> From: Josh Hunt <johunt@akamai.com>
> Date: Mon, 13 Mar 2017 18:34:41 -0500
>
>> In this particular case they really do want to know total # of bytes
>> in the receive queue, not the data bytes they can consume from an
>> application pov. The kernel currently only exposes this value through
>> netlink or /proc/net/udp from what I saw.
>
> Can you explain in what way this is useful?
>
> The difference between skb->len and skb->truesize is really kernel
> internal implementation detail, and I'm trying to figure out why
> this would be useful to an application.
>

First, it looks like my original patch was against an old kernel which 
did not have the updated udp accounting code. Not sure how that 
happened. Apologies for that. There's no need to add in the backlog, at 
least for udp now, sk_rmem_alloc is all that is needed for my case.

The application here is interested in monitoring the amount of data in 
the receive buffer. Looking for and identifying overflows, and also 
understanding how full it is. I know we already have SO_RXQ_OVFL, but 
this only shows the # of drops on overflow.

We expose this (skmem) information via /proc and netlink today. It seems 
like unnecessary overhead to require an application to also create a 
netlink socket to get this data.

Creating a socket option to mimic the behavior of 
sock_diag_put_meminfo() and export all meminfo_vars would be great if 
that's something you'd accept.

Josh
