From: "David S. Miller" <davem@redhat.com>
Subject: Re: How to count tx and rx bytes?
Date: Mon, 15 Dec 2003 14:17:29 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031215141729.15387fc1.davem@redhat.com>
References: <3FDE13AE.3050402@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <3FDE13AE.3050402@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 15 Dec 2003 12:03:58 -0800
Ben Greear <greearb@candelatech.com> wrote:

> Is there an agreed upon standard for exactly what ethernet drivers
> should be counting for rx-bytes and tx-bytes?  For example, should the
> counters include the 4-byte FCS?  Should they include the ethernet header?

Good question.

It should be that all drivers use what skb->len ends up with at
rx/tx time.

However, it is often faster to just let the hardware keep track
of these statistics (tg3 is one example of a chip that can do
this).  And sometimes these mechanisms take the FCS or whatever
into account and this as you note makes the numbers different.
