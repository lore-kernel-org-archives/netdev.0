From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [PATCH] net/icmp: restore source address if packet is NATed
Date: Mon, 26 Jun 2017 00:52:09 +0200
Message-ID: <CAHmME9pJ3bFR+hk6zb71SYzgamy7qHS7TY20qdw3EcCHp5Ghsw@mail.gmail.com>
References: <20170624021727.17835-1-Jason@zx2c4.com> <20170625.114927.1055286919675288173.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170625.114927.1055286919675288173.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

On Sun, Jun 25, 2017 at 5:49 PM, David Miller <davem@davemloft.net> wrote:
> This violates things on so many levels.

Yes, indeed.

> I think this kind of thing need to be hidden inside of netfilter,
> it can do the rate limiting and stuff like that in the spot
> where it makes the transformation and knows all of the original
> addressing and ports.

Indeed I'd prefer that, and I'll look again into trying to make that
work. But when I tried last, it seemed like there were some
insurmountable challenges. With the ratelimiting, the limit has
already been applied to one IP -- the masqueraded one -- before
netfilter even has a chance to act -- so that IP will already hit the
ratelimits well before any additional one inside netfilter would. Then
the issue of transformation: last I looked it seemed like icmp_send
threw away a bit too much information to do the transformation
entirely correctly, but I could be wrong, so I'll give it another
look. Hopefully it winds up being as easy as just reverse-transforming
ICMP's payload IP header.

>
> You definitely can't just rewrite header fields here either.  The
> SKB could be shared, for example.

I was afraid of that. It's easy to rework this particular patch,
though, if you're still interested in the crufty bolt on approach...
But I think I should investigate the netfilter-only approach instead,
as you suggested.

Jason
