From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
Subject: Re: [PATCH 1/3] ixgbe,
 ixgbevf: Add new mbox API to enable MC promiscuous mode
Date: Tue, 10 Feb 2015 02:28:49 +0000
Message-ID: <7F861DC0615E0C47A872E6F3C5FCDDBD05E29F43@BPXM14GP.gisp.nec.co.jp>
References: <7F861DC0615E0C47A872E6F3C5FCDDBD05E1908D@BPXM14GP.gisp.nec.co.jp>
	<1423054641.2589.59.camel@jtkirshe-mobl>
	<7F861DC0615E0C47A872E6F3C5FCDDBD05E26E45@BPXM14GP.gisp.nec.co.jp>
	<1423470046.27854.7.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"Choi, Sy Jong" <sy.jong.choi@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	David Laight <David.Laight@ACULAB.COM>,
	Hayato Momma <h-momma@ce.jp.nec.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	=?utf-8?B?QmrDuHJuIE1vcms=?= <bjorn@mork.no>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1423470046.27854.7.camel@jtkirshe-mobl>
Content-Language: ja-JP
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

> > > > Can you please fix up your patches based on my tree:
> > > > git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/queue.git
> > >
> > > Yes. I haven't noticed your tree.
> > > Will resend patches against it.
> > >
> >
> > I encountered an issue with your tree, the commit id is below.
> >
> > $ git log | head
> > commit e6f1649780f8f5a87299bf6af04453f93d1e3d5e
> > Author: Rasmus Villemoes <linux@rasmusvillemoes.dk>
> > Date:   Fri Jan 23 20:43:14 2015 -0800
> >
> >     ethernet: fm10k: Actually drop 4 bits
> >
> >     The comment explains the intention, but vid has type u16. Before the
> >     inner shift, it is promoted to int, which has plenty of space for all
> >     vid's bits, so nothing is dropped. Use a simple mask instead.
> >
> >
> > I use the kernel from your tree in both host and guest.
> >
> > Assign an IPv6 for VF in guest.
> > # ip -6 addr add 2001:db8::18:1/64 dev ens0
> >
> > Send ping packet from other server to the VM.
> > # ping6  2001:db8::18:1 -I eth0
> >
> > The following message was shown.
> > ixgbevf 0000:00:08.0: partial checksum but l4 proto=3a!
> >
> > If I did the same operation in the host, I saw the same error message in host too.
> > ixgbe 0000:2d:00.0: partial checksum but l4 proto=3a!
> >
> > Do you have any idea about that?
> 
> Ah, sorry about that, try this tree again:
> git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/queue.git
> 
> That patch was dropped for favor of a patch that Matthew Vick put
> together (and recently got pushed upstream).  So my queue no longer has
> that patch in the queue, since it got dropped.

I still see the same error, the head id is the below

$ git log | head
commit a072afb0b45904022b76deef3b770ee9a93cb13a
Author: Nicholas Krause <xerofoify@gmail.com>
Date:   Mon Feb 9 00:27:00 2015 -0800

    igb: Remove outdated fix me comment in the function,gb_acquire_swfw_sync_i210


thanks,
Hiroshi
------------------------------------------------------------------------------
Dive into the World of Parallel Programming. The Go Parallel Website,
sponsored by Intel and developed in partnership with Slashdot Media, is your
hub for all things parallel software development, from weekly thought
leadership blogs to news, videos, case studies, tutorials and more. Take a
look and join the conversation now. http://goparallel.sourceforge.net/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
