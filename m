From: Dmitry Yusupov <dmitry_yus@yahoo.com>
Subject: Re: [Ksummit-2005-discuss] Summary of 2005 Kernel Summit Proposed
	Topics
Date: Sun, 27 Mar 2005 00:18:13 -0800
Message-ID: <1111911493.5824.12.camel@mylaptop>
References: <4241D106.8050302@cs.wisc.edu>
	 <20050324101622S.fujita.tomonori@lab.ntt.co.jp>
	 <1111628393.1548.307.camel@beastie>
	 <20050324113312W.fujita.tomonori@lab.ntt.co.jp>
	 <1111633846.1548.318.camel@beastie> <20050324215922.GT14202@opteron.random>
	 <424346FE.20704@cs.wisc.edu> <20050324233921.GZ14202@opteron.random>
	 <20050325034341.GV32638@waste.org> <20050327035149.GD4053@g5.random>
	 <20050327054831.GA15453@waste.org> <1111905181.4753.15.camel@mylaptop>
	 <20050326224621.61f6d917.davem@davemloft.net>
	 <1111907130.4753.32.camel@mylaptop>
	 <20050326235712.25f9ca36.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: mpm@selenic.com, andrea@suse.de, michaelc@cs.wisc.edu,
        James.Bottomley@HansenPartnership.com, ksummit-2005-discuss@thunk.org,
        netdev@oss.sgi.com
To: "open-iscsi@googlegroups.com" <open-iscsi@googlegroups.com>
In-Reply-To: <20050326235712.25f9ca36.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2005-03-26 at 23:57 -0800, David S. Miller wrote:
> On Sat, 26 Mar 2005 23:05:30 -0800
> Dmitry Yusupov <dmitry_yus@yahoo.com> wrote:
> 
> > > During these gaps in time, you will need to keep your HW receive
> > > ring populated with packets.
> > 
> > ethernet flow-control must take care this case.
> > 
> > If driver's replenish logic could mix alloc_skb/netif_rx and SKB
> > recycling than pause frames should never happen even with gige+
> > interfaces.
> 
> I don't see what the big deal is if pause frames
> are generated when the system is low on atomic memory
> and RX allocations thus fail.

not a big deal may be. but. very interesting case when OOM causing
paging in/out and swapping device are on the same network under iSCSI
control. (disk-less setups) having reliable receive in that case is
important for making progress for READ operations.

> SKB recycling doesn't get the user on the cpu faster
> to receive the data.  I don't understand how you expect
> the recycling to be guarenteed except perhaps as a special
> case for iSCSI taking in the TCP packets in the ->data_ready()
> callback.  In that case it's exactly that, a special case
> hack, and not something generically useful at all.

right. this is what Open-iSCSI project is using for READs.
