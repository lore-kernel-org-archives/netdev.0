From: "David S. Miller" <davem@redhat.com>
Subject: Re: TCP IP Offloading Interface
Date: Sun, 13 Jul 2003 17:24:14 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030713172414.5c888094.davem@redhat.com>
References: <ODEIIOAOPGGCDIKEOPILCEMBCMAA.alan@storlinksemi.com>
	<20030713004818.4f1895be.davem@redhat.com>
	<52u19qwg53.fsf@topspin.com>
	<20030713160200.571716cf.davem@redhat.com>
	<20030713233503.GA31793@work.bitmover.com>
	<20030713164003.21839eb4.davem@redhat.com>
	<20030713235424.GB31793@work.bitmover.com>
	<20030713165323.3fc2601f.davem@redhat.com>
	<20030714002200.GA24697@work.bitmover.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: lm@bitmover.com, roland@topspin.com, alan@storlinksemi.com,
   linux-kernel@vger.kernel.org, linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Larry McVoy <lm@bitmover.com>
In-Reply-To: <20030714002200.GA24697@work.bitmover.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 13 Jul 2003 17:22:00 -0700
Larry McVoy <lm@bitmover.com> wrote:

> Hey, maybe it isn't, but could you please quantify the cost of the VM 
> operations?  How hard is that?

Ok.

So the page is in a non-uptodate state, NFS would have it locked,
and anyone else trying to get at it would sleep.

This page we have currently is "dummy" in that it is only a place
holder in case we don't get a full page from the networking.

We have all the infrastructure to do everything up to this point.

Next, if the networking gave us a full page, we'd "replace"
the dummy page with this one, which would involve:

1) delete the dummy page from the lookup, insert the networking's
   page

2) arrange so that all sleepers on the dummy page will do a relookup
   and find the new page

And when we're done with the operation we wake everyone up.

I can't see any part of this turning out to be expensive.
