From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] PKT_SCHED: Fix double locking in tcindex destroy path
Date: Mon, 20 Dec 2004 15:36:24 -0800
Message-ID: <20041220153624.58a1d93e.davem@davemloft.net>
References: <20041210014918.GT1371@postel.suug.ch>
	<41B90B81.1020102@trash.net>
	<20041210124445.GV1371@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041210124445.GV1371@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 10 Dec 2004 13:44:45 +0100
Thomas Graf <tgraf@suug.ch> wrote:

> * Patrick McHardy <41B90B81.1020102@trash.net> 2004-12-10 03:35
> > Thomas Graf wrote:
> > 
> > >tcindex's destroy uses its own delete functions to destroy its
> > >configuration. The delete function (correctly) takes the qdisc_tree_lock
> > >to prevent list walkings from happening while removing from the list.
> > >The qdisc_tree_lock is already held if we're comming via the destroy
> > >path and thus a double locking takes place.
> > >
> > >Patch not needed for 2.4 since both destroy paths are unlocked but will
> > >be needed if we add them.
> > > 
> > >
> > Looks correct, but 2.4 does need this. qdisc_destroy in 2.4 always
> > happens under dev->queue_lock. For example dev_shutdown from 2.4:
> 
> Not 100% correct since cls_api.c drops the lock before calling
> tcf_destroy but the patch is indeed needed and it's not a problem
> if dev->queue_lock is not taken since it is already unlinked as you
> correctly stated in your previous mail. Thanks Patrick.
> 
> Patch also applies to 2.4 with some fuzz.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

I think the conditional locking is quite ugly, but I can't
suggest something better at this time.

Patch applied to both 2.4.x and 2.6.x, thanks Patrick
and Thomas.
