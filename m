From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Fix loopback over bridge port
Date: Thu, 1 Jan 2004 12:38:14 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040101123814.15fdc875.davem@redhat.com>
References: <200312271536.46940.bdschuym@pandora.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Bart De Schuymer <bdschuym@pandora.be>
In-Reply-To: <200312271536.46940.bdschuym@pandora.be>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 27 Dec 2003 15:36:46 +0100
Bart De Schuymer <bdschuym@pandora.be> wrote:

> I think the code (in net/ipv4/ip_output.c::ip_dev_loopback_xmit())
> __skb_pull(newskb, newskb->nh.raw - newskb->data);
> is useless, as data always points to the network header at that moment. But
> that's not really my territory...

I think you're right about this, but the code there doesn't cause any
problems either, effectively it's a NOP.

One could test out whether you and I are right or not by replacing the
__skb_pull() call with BUG_TRAP(skb->nh.raw == skb->data)
