From: Julia Cartwright <julia@ni.com>
Subject: Re: Kernel 4.6.7-rt13: Intel Ethernet driver igb causes huge
 latencies in cyclictest
Date: Fri, 14 Oct 2016 14:55:36 -0500
Message-ID: <20161014195536.GB27124@jcartwri.amer.corp.natinst.com>
References: <584755c2766e4b94a604ece16760fe14@FE-MBX1012.de.bosch.com>
 <20161005155959.GH10625@jcartwri.amer.corp.natinst.com>
 <13c3cd3ffee4490fb22b8de383e51361@FE-MBX1012.de.bosch.com>
 <AAEA33E297BCAC4B9BB20A7C2DF0AB8D8045E418@FMSMSX113.amr.corp.intel.com>
 <29250f87b1d84aacb8aa312935582291@FE-MBX1012.de.bosch.com>
 <20161010193958.GE22235@jcartwri.amer.corp.natinst.com>
 <e9661abf93194ad3849e3864a8361993@FE-MBX1012.de.bosch.com>
 <b77ea8ab312149d2b20a717d3ab0a8dc@FE-MBX1012.de.bosch.com>
 <20161013161839.GV10625@jcartwri.amer.corp.natinst.com>
 <f395ea6cd1274fac83d2744121da7441@FE-MBX1012.de.bosch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Williams, Mitch A" <mitch.a.williams@intel.com>,
        "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
        "linux-rt-users@vger.kernel.org" <linux-rt-users@vger.kernel.org>,
        Sebastian Andrzej Siewior <sebastian.siewior@linutronix.de>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        Greg <gvrose8192@gmail.com>
To: "Koehrer Mathias (ETAS/ESW5)" <mathias.koehrer@etas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from skprod3.natinst.com ([130.164.80.24]:37488 "EHLO ni.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1756328AbcJNTzw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 14 Oct 2016 15:55:52 -0400
In-Reply-To: <f395ea6cd1274fac83d2744121da7441@FE-MBX1012.de.bosch.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 14, 2016 at 08:58:22AM +0000, Koehrer Mathias (ETAS/ESW5) wrote:
> Hi Julia,
>
> > Have you tested on a vanilla (non-RT) kernel?  I doubt there is anything RT specific
> > about what you are seeing, but it might be nice to get confirmation.  Also, bisection
> > would probably be easier if you confirm on a vanilla kernel.
> >
> > I find it unlikely that it's a kernel config option that changed which regressed you, but
> > instead was a code change to a driver.  Which driver is now the question, and the
> > surface area is still big (processor mapping attributes for this region, PCI root
> > complex configuration, PCI brige configuration, igb driver itself, etc.).
> >
> > Big enough that I'd recommend a bisection.  It looks like a bisection between 3.18
> > and 4.8 would take you about 18 tries to narrow down, assuming all goes well.
> >
>
> I have now repeated my tests using the vanilla kernel.
> There I got the very same issue.
> Using kernel 4.0 is fine, however starting with kernel 4.1, the issue appears.

Great, thanks for confirming!  That helps narrow things down quite a
bit.

> Here is my exact (reproducible) test description:
> I applied the following patch to the kernel to get the igb trace.
> This patch instruments the igb_rd32() function to measure the call
> to readl() which is used to access registers of the igb NIC.

I took your test setup and ran it between 4.0 and 4.1 on the hardware on
my desk, which is an Atom-based board with dual I210s, however I didn't
see much difference.

However, it's a fairly simple board, with a much simpler PCI topology
than your workstation.  I'll see if I can find some other hardware to
test on.

[..]
> This means, that I think that some other stuff in kernel 4.1 has changed,
> which has impact on the igb accesses.
>
> Any idea what component could cause this kind of issue?

Can you continue your bisection using 'git bisect'?  You've already
narrowed it down between 4.0 and 4.1, so you're well on your way.

Another option might be to try to eliminate igb from the picture as
well, and try reading from another device from the same (or, perhaps
nearest) bus segment, and see if you see the same results.

   Julia
