From: Colin Leroy <colin@colino.net>
Subject: Re: [PATCH] Prevent netpoll hanging when link is down
Date: Thu, 7 Oct 2004 10:33:32 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041007103332.688393e3@pirandello>
References: <20041006232544.53615761@jack.colino.net>
	<20041006214322.GG31237@waste.org>
	<20041007075319.6b31430d@jack.colino.net>
	<20041006234912.66bfbdcc.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mpm@selenic.com, akpm@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20041006234912.66bfbdcc.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 06 Oct 2004 at 23h10, David S. Miller wrote:

Hi, 

Thanks for your help.

> I could see it that if gp->hw_running is non-zero, we could run into

You meant zero here ? (or didn't I understand something)

> troubles.  np->dev->poll_controller() will run, and it won't do
> anything since the gem_interrupt() call is a nop when gp->hw_running
> is zero. Then we blindly call ingo np->dev->poll()

Btw, shouldn't gem_poll() check for gp->hw_running, too?
 
> Folks debugging this should verify that gp->hw_running is non-zero
> when the problematic case runs.
 
I added a printk at the end of gem_open(), it's 1 even when there's no
link:

...
netconsole: device eth0 not up yet, forcing it
eth0: gp->hw_running after gem_open: 1
netconsole: timeout waiting for carrier
netconsole: network logging started
...

To be more precise about the netpoll-related hanging: it hangs
after a few messages. From what I remember (90% sure, i'm not in front
of the laptop right now so can't make it crash, it'll be harder to debug
after ^^), it hangs after printing hda init stuff, which is 32 lines
after "netconsole: network logging started" (MAX_SKBS == 32 in
netpoll.c)...

How stupid, I just added a printk at the beginning of netpoll_send_skb
and rebooted, and the laptop doesn't get back online. Bitten by
recursion once again... I should have thought harder first.

-- 
Colin
