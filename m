From: "David S. Miller" <davem@redhat.com>
Subject: Re: [RFC] add rtnl semaphore to linux-atm
Date: Fri, 3 Oct 2003 06:58:24 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031003065824.713627c6.davem@redhat.com>
References: <200310011134.h91BYPkT003172@ginger.cmf.nrl.navy.mil>
	<20031001054226.126cea7b.davem@redhat.com>
	<20031003022615.GA42593@gaz.sfgoth.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: chas3@users.sourceforge.net, chas@cmf.nrl.navy.mil, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Mitchell Blank Jr <mitch@sfgoth.com>
In-Reply-To: <20031003022615.GA42593@gaz.sfgoth.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2 Oct 2003 19:26:15 -0700
Mitchell Blank Jr <mitch@sfgoth.com> wrote:

> My personal recommendations:
>   * There should be a per-atm-device semaphore held across calls into the
>     driver's ->open, ->close, ->change_qos and maybe a couple other things
>     to serialize those operations (for the sake of keeping the drivers
>     sane - there's no reason there should be multiple operations pending)

Ok, but what Chas is trying to do is move the ATM device stuff over
to a model that makes use of the existing network device infrastructure
for solving these kinds of problems.

Part of that is using the rtnl semaphore etc.

I would rather Chas use the rtnl semaphore for synchronization
than to ultra-optimize this code by using the rwlock as I had suggested
to him.
