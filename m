From: Andy Lutomirski <luto@stanford.edu>
Subject: Re: [PATCH r8169] ethtool support and sane speed selection/detection
Date: Sat, 24 Apr 2004 08:05:54 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <408A8252.5040006@stanford.edu>
References: <20040424050931.14C341D4F@luto.stanford.edu> <20040424124453.A25284@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andy Lutomirski <luto@myrealbox.com>, netdev@oss.sgi.com,
        jgarzik@pobox.com, Jon D Mason <jonmason@us.ibm.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20040424124453.A25284@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Francois Romieu wrote:

> [Jeff Garzik added to the loop]
> [If nobody disagrees, I'll remove l-k from the Cc: during the next round]

done - my bad.

>>As an added benefit, my 8001S often fails to negotiate 1000Mbps when the
>>driver loads but will successfully negotiate it after a while.  Running
>>'ethtool -s ethx autoneg on' fixes it, but that's absurd.  This patch
>>will, ten seconds after the driver starts, check if 1000Mbps is advertised
>>but not selected, and, if so, force a renegotiation.
> 
> 
> So you can not reliably remove the phy timer and simply use the LinkChg status
> change, right ?

Apparently.  The timer only fires when necessary with my patch, though 
(see the return statements in rtl8169_phy_timer).

BTW, what was it there for in the first place?  I can get gigabit to 
fail to negotiate, but I always pick up a 100Mbps/full duplex link when 
that happens.  I've never seen a complete absense of link.  I left the 
original semantics around because I assumed there was a reason, but if 
it's unnecessary, then the timer should only need to fire once during 
the lifetime of the device (and the assorted bookkeeping can go away).

> 
> Is everybody fine if I cook up a serie of patches for -netdev/-mm inclusion
> which includes:
> - your link related changes
> - start of a 8139cp.c genetic mutation on top of those
> - reworked Jon D Mason's NAPI changes

Fine by me.

One other question:  I was once able to put the chipset into a state 
where it appeared to have lost all software control over the PHY 
(LinkChg never fired, the link always appeared to be down, changing 
allowed link modes, resetting the phy, and forcing renegotiation did 
nothing, but the link still worked).  This problem survived reload of my 
driver, reload of the unmodified driver, a warm reboot and a cold 
reboot; I fixed it by turning off the computer, then unplugging the 
power supply, and then turning it on to discharge the standby voltage. 
Do you know any way to do an extra hard reset of the chipset?


Any thoughts on what's wrong with my tx csum offload patch?  If I can 
get that working, I'll do rx csum offload and TSO as well.

--Andy

> 
> ETA: this week end, start of incoming week.
> 
> --
> Ueimor
