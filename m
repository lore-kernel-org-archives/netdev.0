From: Roger Luethi <rl@hellgate.ch>
Subject: Re: [9/9][PATCH 2.6] Add WOL support
Date: Sun, 20 Jun 2004 00:15:13 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040619221513.GB3313@k3.hellgate.ch>
References: <20040615175003.GA11382@k3.hellgate.ch> <40D4B049.6070508@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <40D4B049.6070508@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 19 Jun 2004 17:29:45 -0400, Jeff Garzik wrote:
> >+				reason = "Unicast packet";
> >+				break;
> >+			case WOLbmcast:
> >+				reason = "Multicast/broadcast packet";
> >+				break;
> >+			default:
> >+				reason = "Unknown";
> >+			}
> >+			printk("%s: Woke system up. Reason: %s.\n",
> >+			       DRV_NAME, reason);
> 
> printk needs  KERN_xxx prefix

Oops. Fixed.

> also, use dev->name rather than DRV_NAME, since we are past the probe phase.

Can you define probe phase? ... In the code as is, we haven't called
register_netdev when we execute that part. Getting the probe stuff into
a sane order is on my todo list as well, but ISTR that calling
register_netdev way early is frowned upon. No?

> >+	/* Enable legacy WOL (for old motherboards) */
> >+	writeb(0x01, ioaddr + PwcfgSet);
> >+	writeb(readb(ioaddr + StickyHW) | 0x04, ioaddr + StickyHW);
> >+
> >+	/* Hit power state D3 (sleep) */
> >+	writeb(readb(ioaddr + StickyHW) | 0x03, ioaddr + StickyHW);
> 
> would be nice to eliminate these magic numbers (0x04, 0x04), ...

Mostly agreed. I want to change a bunch of symbol names anyway. However,
I found it easier to document magic numbers that are used only _once_
where they occur instead of giving them a name I have to look up later.
I don't feel strongly about it, though, so feel free to bug me again if
you do :-).

Roger
