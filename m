From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: 3.11-rc6 genetlink locking fix offends lockdep
Date: Tue, 20 Aug 2013 21:10:13 +0200
Message-ID: <1377025813.13829.22.camel@jlt4.sipsolutions.net>
References: <alpine.LNX.2.00.1308182143370.906@eggly.anvils>
	 <1376899214.14734.6.camel@jlt4.sipsolutions.net>
	 <5211FAB3.7080400@huawei.com>
	 <1376911362.14734.11.camel@jlt4.sipsolutions.net>
	 <alpine.LNX.2.00.1308191147350.1505@eggly.anvils>
	 (sfid-20130819_205317_938941_E76DFECF) <1376987338.13829.7.camel@jlt4.sipsolutions.net>
	 <1377025368.13829.21.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ding Tianhong <dingtianhong@huawei.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Greg KH <gregkh@linuxfoundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	"Otcheretianski, Andrei" <andrei.otcheretianski@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>,
	Pravin B Shelar <pshelar@nicira.com>,
	Thomas Graf <tgraf@suug.ch>
To: Hugh Dickins <hughd@google.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1377025368.13829.21.camel@jlt4.sipsolutions.net>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-08-20 at 21:02 +0200, Johannes Berg wrote:
> On Tue, 2013-08-20 at 10:28 +0200, Johannes Berg wrote:
> 
> > The only way to fix this that I see right now (that doesn't rewrite the
> > locking completely) would be to make genetlink use parallel_ops itself,
> > thereby removing the genl_lock() in genl_rcv_msg() and breaking all
> > those lock chains that lockdep reported. After that, it should be safe
> > to use genl_lock() inside all the operations. Something like the patch
> > below, perhaps? Completely untested so far.
> 
> Tested now, and it still causes lockdep to complain, though that's a
> lockdep issue I believe, it thinks that genl_mutex and nlk->cb_mutex can
> be inverted although nlk->cb_mutex exists per family, so we need to
> annotate lockdep there.

No, lockdep is correct - generic netlink uses the same cb_mutex for all
families, obviously, since it's all the same netlink family.

I'll just convert it to RCU.

johannes
