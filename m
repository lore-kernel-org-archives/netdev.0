From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: 3.11-rc6 genetlink locking fix offends lockdep
Date: Mon, 19 Aug 2013 13:22:42 +0200
Message-ID: <1376911362.14734.11.camel@jlt4.sipsolutions.net>
References: <alpine.LNX.2.00.1308182143370.906@eggly.anvils>
	 <1376899214.14734.6.camel@jlt4.sipsolutions.net>
	 <5211FAB3.7080400@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Hugh Dickins <hughd@google.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Greg KH <gregkh@linuxfoundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	"Otcheretianski, Andrei" <andrei.otcheretianski@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>,
	Pravin B Shelar <pshelar@nicira.com>,
	Thomas Graf <tgraf@suug.ch>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5211FAB3.7080400@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-08-19 at 19:00 +0800, Ding Tianhong wrote:
> On 2013/8/19 16:00, Johannes Berg wrote:
> > 
> >> 3.11-rc6's commit 58ad436fcf49 ("genetlink: fix family dump race")
> >> gives me the lockdep trace below at startup.
> > 
> > Hmm. Yes, I see now how this happens, not sure why I didn't run into it.
> > 
> > The problem is that genl_family_rcv_msg() is called with the genl_lock
> > held, and then calls netlink_dump_start() with it held, creating a
> > genl_lock->cb_mutex dependency, but obviously the dump continuation is
> > the other way around.
> > 
> > We could use the semaphore instead, I believe, but I don't really
> > understand the mutex vs. semaphore well enough to be sure that's
> > correct.
> > 
> > johannes
> > 
> it is useless, the logic need to modify or otherwise it will still call lockdep trace.

I don't believe so, the semaphore and cb_mutex don't have a dependency
yet, afaict.

> maybe i could send a patch for it, if you wish.

What do you mean?

johannes
