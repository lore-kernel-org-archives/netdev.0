From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v2] qed: mark symbols static where possible
Date: Thu, 08 Sep 2016 15:00:22 +0200
Message-ID: <2655062.3nWxjufk2r@wuerfel>
References: <1473323117-8772-1-git-send-email-baoyou.xie@linaro.org> <DM5PR11MB172334FF9A978C71E05A0B4197FB0@DM5PR11MB1723.namprd11.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Baoyou Xie <baoyou.xie@linaro.org>,
        David Miller <davem@davemloft.net>,
        Dept-Eng Everest Linux L2 <Dept-EngEverestLinuxL2@qlogic.com>,
        netdev <netdev@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        "xie.baoyou@zte.com.cn" <xie.baoyou@zte.com.cn>,
        Ariel Elior <Ariel.Elior@qlogic.com>
To: Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <DM5PR11MB172334FF9A978C71E05A0B4197FB0@DM5PR11MB1723.namprd11.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday, September 8, 2016 12:37:13 PM CEST Yuval Mintz wrote:
> > 1. qed_get_vport_stats() is in use in net-next by qed_main.c starting 
> > with
> > 6c75424612a7 ("qed: Add support for NCSI statistics."), so we 
> > shouldn't make it static.
> 
> Besides, it still doesn't apply to net-next
> [as net-next has function declaration as a single liner].

Baoyou, I recommended earlier that you start the work on a mainline
kernel, but in particular for fast-moving subsystems it is better
to use linux-next as the base.

This means rebasing your patches every day before sending out stuff,
which is some extra work, but you have a much better chance of the
patches actually applying to the respective subsystem maintainer trees.

It also helps to see if a particular file you are changing was
modified in linux-next. The  trick I use for that is

$ git log --oneline --no-merges torvalds/master..next/master drivers/net/ethernet/qlogic/qed | head
e0971c832af4 qed*: Add support for the ethtool get_regs operation
c965db444629 qed: Add support for debug data collection
72e8d5fdf58b qed: add missing header dependencies
4102426f9b7b qed: Add infrastructure for debug data collection
2591c280c375 qed: Remove OOM messages
561ed23331df qed: fix kzalloc-simple.cocci warnings
c5e801dac4da qed: Clear dcbx memory buffers before the usage.
5ec5dfa4d294 qed: Set selection-field while configuring the app entry in ieee mode.
5fe118c9fd6b qed*: Disallow dcbx configuration for VF interfaces.
b0bccb69eba3 qed: Change locking scheme for VF channel

followed by looking at who merged the top commit

$ git log --ancestry-path --oneline --merges e0971c832af4..next/master | tail
7a700727059a Merge remote-tracking branch 'mtd/master'
d7445193092f Merge remote-tracking branch 'rdma/for-next'
9ecd4508b2e9 Merge remote-tracking branch 'mac80211-next/master'
b74f90413edd Merge remote-tracking branch 'bluetooth/master'
dc9e43436ac5 Merge remote-tracking branch 'wireless-drivers-next/master'
ae8d88338957 Merge remote-tracking branch 'ipvs-next/master'
1e786a88da29 Merge remote-tracking branch 'netfilter-next/master'
3a883dcccac5 Merge remote-tracking branch 'ipsec-next/master'
bef876902277 Merge remote-tracking branch 'net-next/master'
e6f3f120827c Merge branch 'qed-debug-data-collection'

which tells you that it came from a branch called qed-debug-data-collection
into net-next and from there into linux-next.

	Arnd
