From: "David S. Miller" <davem@redhat.com>
Subject: Re: tunnel xmit and h.raw
Date: Tue, 7 Oct 2003 08:32:37 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031007083237.1de6e10a.davem@redhat.com>
References: <Pine.LNX.4.44.0310030252070.1394-100000@u.domain.uli>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Julian Anastasov <ja@ssi.bg>
In-Reply-To: <Pine.LNX.4.44.0310030252070.1394-100000@u.domain.uli>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 3 Oct 2003 03:00:27 +0300 (EEST)
Julian Anastasov <ja@ssi.bg> wrote:

> # --------------------------------------------
> # 03/10/03	ja@ssi.bg	1.1357
> # [IPV4/IPV6]: tunnel xmit must load skb->h.raw after all reallocations
> # --------------------------------------------

I've applied this, it is absolutely correct.

While studying this I've discovered some deeper problems.
The skb_shared() checks in these tunnel drivers is bogus,
on transmit skb->users should never ever be anything but 1.

Besides the tunnel drivers, the loopback driver and ipmr.c
do similar things in their ->hard_start_xmit() handlers.
In particular, the ipmr.c case is really in bad shape.

I've put fixing this onto the todo list...
