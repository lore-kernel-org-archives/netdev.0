From: "David S. Miller" <davem@redhat.com>
Subject: Re: [RFC] add rtnl semaphore to linux-atm
Date: Fri, 3 Oct 2003 22:16:40 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031003221640.19aa485f.davem@redhat.com>
References: <200310011134.h91BYPkT003172@ginger.cmf.nrl.navy.mil>
	<20031001054226.126cea7b.davem@redhat.com>
	<20031003022615.GA42593@gaz.sfgoth.com>
	<20031003065824.713627c6.davem@redhat.com>
	<20031003214541.GA73152@gaz.sfgoth.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: chas3@users.sourceforge.net, chas@cmf.nrl.navy.mil, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Mitchell Blank Jr <mitch@sfgoth.com>
In-Reply-To: <20031003214541.GA73152@gaz.sfgoth.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 3 Oct 2003 14:45:41 -0700
Mitchell Blank Jr <mitch@sfgoth.com> wrote:

> We *can't* use it to protect the state of the vcc list though because we
> need to do lookups in both interrupt and bh context.  Using a sleeping
> lock alone is a non-starter.
> 
> That's why we need to do the three-step spinlock->semaphore->spinlock
> dance in the vcc open and close paths.

The semaphore protects "modifications", it basically serializes them.

You still need a rwlock to protect the actual lists and this rwlock
is what the interrupt/bh context code takes to traverse the lists
and tables.

This is how the netdev list works, for example.
