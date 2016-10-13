From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: Kernel 4.6.7-rt13: Intel Ethernet driver igb causes huge
 latencies in cyclictest
Date: Thu, 13 Oct 2016 14:02:15 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB01E7AC1@AcuExch.aculab.com>
References: <20160923144140.5tkzeymamrb5qnsv@linutronix.de>
 <a5ea146cf078457ab001131ca0886b0b@FE-MBX1012.de.bosch.com>
 <20160928194519.GA32423@jcartwri.amer.corp.natinst.com>
 <487032ca81f84e70bdacc39a024eff5e@FE-MBX1012.de.bosch.com>
 <20161004193445.GF10625@jcartwri.amer.corp.natinst.com>
 <584755c2766e4b94a604ece16760fe14@FE-MBX1012.de.bosch.com>
 <20161005155959.GH10625@jcartwri.amer.corp.natinst.com>
 <13c3cd3ffee4490fb22b8de383e51361@FE-MBX1012.de.bosch.com>
 <AAEA33E297BCAC4B9BB20A7C2DF0AB8D8045E418@FMSMSX113.amr.corp.intel.com>
 <29250f87b1d84aacb8aa312935582291@FE-MBX1012.de.bosch.com>
 <20161010193958.GE22235@jcartwri.amer.corp.natinst.com>
 <e9661abf93194ad3849e3864a8361993@FE-MBX1012.de.bosch.com>
 <b77ea8ab312149d2b20a717d3ab0a8dc@FE-MBX1012.de.bosch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "linux-rt-users@vger.kernel.org" <linux-rt-users@vger.kernel.org>,
        Sebastian Andrzej Siewior <sebastian.siewior@linutronix.de>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        Greg <gvrose8192@gmail.com>
To: "'Koehrer Mathias (ETAS/ESW5)'" <mathias.koehrer@etas.com>,
        "Julia Cartwright" <julia@ni.com>,
        "Williams, Mitch A" <mitch.a.williams@intel.com>,
        "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.193]:55457 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751638AbcJMOk3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2016 10:40:29 -0400
In-Reply-To: <b77ea8ab312149d2b20a717d3ab0a8dc@FE-MBX1012.de.bosch.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Koehrer Mathias
> Sent: 13 October 2016 11:57
..
> > The time between my trace points 700 and 701 is about 30us, the time between my
> > trace points 600 and 601 is even 37us!!
> > The code in between is
> >      tsyncrxctl = rd32(E1000_TSYNCRXCTL); resp.
> >      lvmmc = rd32(E1000_LVMMC);
> >
> > In both cases this is a single read from a register.
> > I have no idea why this single read could take that much time!
> > Is it possible that the igb hardware is in a state that delays the read access and this is
> > why the whole I/O system might be delayed?
> >
> 
> To have a proper comparison, I did the same with kernel 3.18.27-rt27.
> Also here, I instrumented the igb driver to get traces for the rd32 calls.
> However, here everything is generally much faster!
> In the idle system the maximum I got for a read was about 6us, most times it was 1-2us.

1-2us is probably about right, PCIe is high throughput high latency.
You should see the latencies we get talking to fpga!

> On the 4.8 kernel this is always much slower (see above).
> My question is now: Is there any kernel config option that has been introduced in the meantime
> that may lead to this effect and which is not set in my 4.8 config?

Have a look at the generated code for rd32().
Someone might have added a load of synchronisation instructions to it.
On x86 I don't think it needs any.

It is also possible for other PCIe accesses to slow things down
(which might be why you see 6us).

I presume you are doing these comparisons on the same hardware?
Obscure bus topologies could slow things down.

	David
