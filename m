From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
Subject: Re: [PATCH 1/2] if_link: Add VF multicast
	promiscuous	mode control
Date: Wed, 21 Jan 2015 12:18:23 +0000
Message-ID: <7F861DC0615E0C47A872E6F3C5FCDDBD05E090FE@BPXM14GP.gisp.nec.co.jp>
References: <7F861DC0615E0C47A872E6F3C5FCDDBD05E0734E@BPXM14GP.gisp.nec.co.jp>
	<874mrlu18e.fsf@nemi.mork.no>
	<7F861DC0615E0C47A872E6F3C5FCDDBD05E07B7C@BPXM14GP.gisp.nec.co.jp>
	<F6FB0E698C9B3143BDF729DF222866469129B7F5@ORSMSX110.amr.corp.intel.com>
	<7F861DC0615E0C47A872E6F3C5FCDDBD05E07F09@BPXM14GP.gisp.nec.co.jp>
	<F6FB0E698C9B3143BDF729DF222866469129B844@ORSMSX110.amr.corp.intel.com>
	<7F861DC0615E0C47A872E6F3C5FCDDBD05E08FF6@BPXM14GP.gisp.nec.co.jp>
	<063D6719AE5E284EB5DD2968C1650D6D1CAD01D6@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>, "Choi,
	Sy Jong" <sy.jong.choi@intel.com>, Hayato Momma <h-momma@ce.jp.nec.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	=?utf-8?B?QmrDuHJuIE1vcms=?= <bjorn@mork.no>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CAD01D6@AcuExch.aculab.com>
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

> Subject: RE: [E1000-devel] [PATCH 1/2] if_link: Add VF multicast promiscuous mode control
> 
> From: Hiroshi Shimamoto
> > My concern is what is the real issue that VF multicast promiscuous mode can cause.
> > I think there is the 4k entries to filter multicast address, and the current ixgbe/ixgbevf
> > can turn all bits on from VM. That is almost same as enabling multicast promiscuous mode.
> > I mean that we can receive all multicast addresses by an onerous operation in untrusted VM.
> > I think we should clarify what is real security issue in this context.
> 
> If you are worried about passing un-enabled multicasts to users then
> what about doing a software hash of received multicasts and checking
> against an actual list of multicasts enabled for that hash entry.
> Under normal conditions there is likely to be only a single address to check.
> 
> It may (or may not) be best to use the same hash as any hashing hardware
> filter uses.

thanks for the comment. But I don't think that is the point.

I guess, introducing VF multicast promiscuous mode seems to add new privilege
to peek every multicast packet in VM and that doesn't look good.
On the other hand, I think that there has been the same privilege in the current
ixgbe/ixgbevf implementation already. Or I'm reading the code wrongly.
I'd like to clarify what is the issue of allowing to receive all multicast packets.

thanks,
Hiroshi

------------------------------------------------------------------------------
New Year. New Location. New Benefits. New Data Center in Ashburn, VA.
GigeNET is offering a free month of service with a new server in Ashburn.
Choose from 2 high performing configs, both with 100TB of bandwidth.
Higher redundancy.Lower latency.Increased capacity.Completely compliant.
http://p.sf.net/sfu/gigenet
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
