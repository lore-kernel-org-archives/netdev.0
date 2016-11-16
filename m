From: Kast Bernd <kastbernd@gmx.de>
Subject: Re: [PATCH] r8169: Module parameter for opt-in of ASPM
Date: Wed, 16 Nov 2016 01:59:30 +0100
Message-ID: <20161116005930.GA32205@ASUS-Bernd.fritz.box>
References: <20161103233306.GA9368@ASUS-Bernd.fritz.box>
 <20161112.210224.1889131711533608896.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nic_swsd@realtek.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161112.210224.1889131711533608896.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Nov 12, 2016 at 09:02:24PM -0500, David Miller wrote:
> From: Kast Bernd <kastbernd@gmx.de>
> Date: Fri, 4 Nov 2016 00:33:06 +0100
> 
> > This patch adds a module parameter in order to activate ASPM. By that
> > the CPU can enter deep sleep modes (PC6) and power consumption can be
> > reduced (for example from 13W to 8W on my notebook with a Haswell CPU).
> > Basically, it reapplies d64ec841517a25f6d468bde9f67e5b4cffdc67c7, which
> > was reverted due to delayed link status detection and increased boot
> > times on some systems. These bugs are avoided by two actions:
> >         1) ASPM is turned off by default to avoid any problems with the
> > 	default	configuration.
> >         2) Flags for ASPM and clock request are set after ephy_init,
> > 	which wasn't respected on the previous patch. Thus ASPM with
> > 	this patch could work even with previously failing systems.
> 
> This feels like grasping at straws.
> 
> If you feel you've corrected a flaw in the previous ASPM
> support, then let's reinstate it unconditionally without
> some module parameter.
> 
> We'll never find out if you actually did fix ASPM support
> sufficiently if it's off by default.
> 
> Only experts like you will ever enable the option.  It's
> usage will be minimal, and therefore the benefits will not
> be sufficient to justify these changes in the first place.


The correction of that flaw is rather a side effect of reapplying the
old patch. Perhaps it will allow enabling ASPM on some additional
systems, but for sure it won't solve all ASPM related problems.
I know that the module parameters are frowned upon, as Francois Romieu
stated. Nevertheless, nobody commented on his suggestion to overcome
the problem of disabled ASPM (1).
I would really love to see ASPM enabled by default. However, it seems
to be quite unlikely, as it has the potential to trigger bugs and
freezes on some systems. I can understand, that the main focus of the
kernel is stability. Nonetheless, I also mind power consumption.
That's why I used this kernel parameter to provide a simple solution,
which can significantly reduce power consumption and heat production
without affecting stability. If we can achieve that without a kernel
parameter it's perfectly fine for me. From my point of view, there are
only two other solutions:
-a white list, like proposed by Francois Romieu, that enables ASPM on
systems, that are known to work stable
-a black list, that disables ASPM on buggy systems
While the first solution results in lots of work to keep that list up
to date, the second one will lead to unstable systems.
I don't know how many systems are out there, that suffer from problems
that are really caused by ASPM and not by some other bug,as even the
commit (2), that disabled ASPM in general for r8169, cites a bug
report, that doensn't seem to be related to ASPM at all (3).
However, others state, that disabling ASPM solved their problems (4).
Finding the flaws that caused these bugs or listing these systems is
beyond my possibilities. Thus the kernel paramter, although it is not
perfect, seemed to be the best compromise to me.


(1) http://lkml.iu.edu/hypermail/linux/kernel/1605.1/04992.html
(2) 4521e1a94279ce610d3f9b7945c17d581f804242
(3) https://bugzilla.redhat.com/show_bug.cgi?id=642861#c9
(4) https://bugzilla.redhat.com/show_bug.cgi?id=538920
