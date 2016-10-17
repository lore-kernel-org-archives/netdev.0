From: Julia Cartwright <julia@ni.com>
Subject: Re: Kernel 4.6.7-rt13: Intel Ethernet driver igb causes huge
 latencies in cyclictest
Date: Mon, 17 Oct 2016 13:36:45 -0500
Message-ID: <20161017183645.GA9435@jcartwri.amer.corp.natinst.com>
References: <20161005155959.GH10625@jcartwri.amer.corp.natinst.com>
 <13c3cd3ffee4490fb22b8de383e51361@FE-MBX1012.de.bosch.com>
 <AAEA33E297BCAC4B9BB20A7C2DF0AB8D8045E418@FMSMSX113.amr.corp.intel.com>
 <29250f87b1d84aacb8aa312935582291@FE-MBX1012.de.bosch.com>
 <20161010193958.GE22235@jcartwri.amer.corp.natinst.com>
 <e9661abf93194ad3849e3864a8361993@FE-MBX1012.de.bosch.com>
 <b77ea8ab312149d2b20a717d3ab0a8dc@FE-MBX1012.de.bosch.com>
 <20161013161839.GV10625@jcartwri.amer.corp.natinst.com>
 <f395ea6cd1274fac83d2744121da7441@FE-MBX1012.de.bosch.com>
 <20161014220633.GA1811@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "Koehrer Mathias (ETAS/ESW5)" <mathias.koehrer@etas.com>,
        "Williams, Mitch A" <mitch.a.williams@intel.com>,
        "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
        "linux-rt-users@vger.kernel.org" <linux-rt-users@vger.kernel.org>,
        Sebastian Andrzej Siewior <sebastian.siewior@linutronix.de>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        Greg <gvrose8192@gmail.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from skprod2.natinst.com ([130.164.80.23]:45278 "EHLO ni.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S932863AbcJQShB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 17 Oct 2016 14:37:01 -0400
In-Reply-To: <20161014220633.GA1811@netboy>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 15, 2016 at 12:06:33AM +0200, Richard Cochran wrote:
> On Fri, Oct 14, 2016 at 08:58:22AM +0000, Koehrer Mathias (ETAS/ESW5) wrote:
> > @@ -753,7 +756,9 @@ u32 igb_rd32(struct e1000_hw *hw, u32 re
> >  	if (E1000_REMOVED(hw_addr))
> >  		return ~value;
> >  
> > +        trace_igb(801);
> >  	value = readl(&hw_addr[reg]);
> > +        trace_igb(802);
> 
> Nothing prevents this code from being preempted between the two trace
> points, and so you can't be sure whether the time delta in the trace
> is caused by the PCIe read stalling or not.

While that is certainly the case, and would explain the most egregious
of measured latency spikes, it doesn't invalidate the test if you
consider the valuable data point(s) to be the minimum and/or median
latencies.

   Julia
