From: Larry McVoy <lm@bitmover.com>
Subject: Re: TCP IP Offloading Interface
Date: Sun, 13 Jul 2003 16:54:24 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030713235424.GB31793@work.bitmover.com>
References: <ODEIIOAOPGGCDIKEOPILCEMBCMAA.alan@storlinksemi.com> <20030713004818.4f1895be.davem@redhat.com> <52u19qwg53.fsf@topspin.com> <20030713160200.571716cf.davem@redhat.com> <20030713233503.GA31793@work.bitmover.com> <20030713164003.21839eb4.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Larry McVoy <lm@bitmover.com>, roland@topspin.com, alan@storlinksemi.com,
   linux-kernel@vger.kernel.org, linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030713164003.21839eb4.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> The whole point is to not touch any of this data.
> 
> The idea is to push the pages directly into the page cache
> of the filesystem.

It doesn't work.  Measure the cost of the VM operations before you go
down this path.  Just set up a system call that swaps a page with a
kernel allocated buffer and then see how many of those you can do a 
second.  Maybe Linux is so blindingly fast this makes sense but IRIX
certainly wasn't, the VM overhead hurt like crazy.

Every time I tried to push the page flip idea or offloading or any of
that crap, Andy Bechtolsheim would tell "the CPUs will get faster faster
than you can make that work".  He was right.
-- 
---
Larry McVoy              lm at bitmover.com          http://www.bitmover.com/lm
