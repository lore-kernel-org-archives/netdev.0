From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: confuzed bit flags
Date: Thu, 8 May 2003 15:30:32 -0700
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030508153032.06e7c98a.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: linux-net@vger.kernel.org
List-Id: netdev.vger.kernel.org


I'm confused or the source code is or both.

net/ipv6/ndisc.c sets

	rt->rt6i_flags    = RTF_LOCAL;

This is OK AFAIK since RTF_LOCAL is #defined in
./linux/ipv6_route.h:36:#define RTF_LOCAL       0x80000000

But then RTF_LOCAL is never used anywhere else.  OK or not?

Further checking finds that net/ipv6/xfrm6_policy.c does this:

		x->u.rt6.rt6i_flags    = rt0->rt6i_flags&(RTCF_BROADCAST|RTCF_MULTICAST|RTCF_LOCAL);

but these RTCF_ bits are defined in include/linux/in_route.h,
which says:

/* IPv4 routing cache flags */

So it's nice or good that RTF_LOCAL and RTCF_LOCAL are both
#defined as 0x80000000.  Right?

Oh, I see now that there's even a comment that might be applicable
to this <stuff>:
		/* Sheit... I remember I did this right. Apparently,
		 * it was magically lost, so this code needs audit */

I guess that my (idealistic) position is that those RTCF_ bit flags
shouldn't be used here (in net/ipv6) at all.  Am I off track on this?

--
~Randy
