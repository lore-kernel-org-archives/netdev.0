From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH r8169] ethtool support and sane speed selection/detection
Date: Sat, 24 Apr 2004 17:01:02 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040424170102.A27531@electric-eye.fr.zoreil.com>
References: <20040424050931.14C341D4F@luto.stanford.edu> <20040424124453.A25284@electric-eye.fr.zoreil.com> <408A8252.5040006@stanford.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Lutomirski <luto@myrealbox.com>, netdev@oss.sgi.com,
        jgarzik@pobox.com, Jon D Mason <jonmason@us.ibm.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Andy Lutomirski <luto@stanford.edu>
Content-Disposition: inline
In-Reply-To: <408A8252.5040006@stanford.edu>; from luto@stanford.edu on Sat, Apr 24, 2004 at 08:05:54AM -0700
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Re,

Andy Lutomirski <luto@stanford.edu> :
[...]
> done - my bad.

No problem.

[...]
> > So you can not reliably remove the phy timer and simply use the LinkChg
> > status change, right ?
> 
> Apparently.  The timer only fires when necessary with my patch, though 
> (see the return statements in rtl8169_phy_timer).
> 
> BTW, what was it there for in the first place?  I can get gigabit to 
> fail to negotiate, but I always pick up a 100Mbps/full duplex link when 
> that happens.  I've never seen a complete absense of link.  I left the 
> original semantics around because I assumed there was a reason, but if 
> it's unnecessary, then the timer should only need to fire once during 
> the lifetime of the device (and the assorted bookkeeping can go away).

The timer is a survival of Realtek's changes as they appeared in their
release 1.6 of the driver but it does not necessarily means that it can
not be done differently. As Jeff suggested/expects a merge of the r8169
driver within the 8139cp one, a removal of the timer would push the r8169
driver in the right direction. At least that's how I have read your patch
this morning :o)

[completely unresponsive r8169 chipset]
> Do you know any way to do an extra hard reset of the chipset?

It has already been reported but I have not digged it. A comparison of
the registers of the device when it is functionnal/frost may shed some
light on this issue.

[...]
> Any thoughts on what's wrong with my tx csum offload patch?  If I can 
> get that working, I'll do rx csum offload and TSO as well.

So far I have not had time to look closely at your TSO patch. If you want
a working TSO support with minimal pain, getting some inspiration from the
8139cp driver would be imho the way to go. One can expect this kind of new
functions (from a r8169 pov) to be gained from the merge with the 8139cp.c.
So, if you want to publish some TSO patch, it would be nice to write it in
such a way that it does not make the r8169 more different from the 8139cp
driver than it currently is.

--
Ueimor
