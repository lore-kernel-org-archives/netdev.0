From: Andrei Warkentin <awarkentin@vmware.com>
Subject: Re: [PATCHv3 2/3] NETKGDB: Ethernet/UDP/IP KDB transport.
Date: Sun, 26 Feb 2012 21:36:40 -0800 (PST)
Message-ID: <310080656.1570547.1330321000661.JavaMail.root@zimbra-prod-mbox-2.vmware.com>
References: <116798.1330320543@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Andrei Warkentin <andreiw@vmware.com>,
	kgdb-bugreport@lists.sourceforge.net,
	Jason Wessel <jason.wessel@windriver.com>,
	Matt Mackall <mpm@selenic.com>,
	Andrei Warkentin <andrey.warkentin@gmail.com>
To: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <116798.1330320543@turing-police.cc.vt.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

----- Original Message -----
> From: "Valdis Kletnieks" <Valdis.Kletnieks@vt.edu>
> To: "Andrei Warkentin" <andrey.warkentin@gmail.com>
> Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, "Andrei Warkentin" <andreiw@vmware.com>,
> kgdb-bugreport@lists.sourceforge.net, "Jason Wessel" <jason.wessel@windriver.com>, "Matt Mackall" <mpm@selenic.com>
> Sent: Monday, February 27, 2012 12:29:03 AM
> Subject: Re: [PATCHv3 2/3] NETKGDB: Ethernet/UDP/IP KDB transport.
> 
> This *really* needs a discussion of the security implications of
> this.  Do
> you *really* want to have a kgdb that will accept connections from
> *anywhere*?
> Sounds like an insta-root waiting to happen.
> 

It does *really* need documentation. It's not meant for general purpose use.
Just like Android devices come with KDB compiled out, this shouldn't be
built in. That means that netkgdb should be default off and come with a
huge warning. It is insta-root. And that's the message it should carry with it.
It's no different from running kgdboc - anyone has root access if they press
Alt-PrtScrn-g, right?

> > +the assigned interface IP address changes. This makes it useful
> > +in an environment where it's not known ahead of time what computer
> > +will connect to perform the crash analysis.
> 
> Exactly. You don't know ahead of time who's going to connect. That's
> the
> problem...

It's not a problem unless you make it one. If I am running a private test farm
where I provision 250+ machines or VMs, and I have 10-15 devs that could possibly
investigate the issue, it's not realistic to know ahead of times what internal
IP address the connection could come from.

I will update the docs and the Kconfig (default=off). That should be
sufficient for PEBCAK failures.

Cheers,
A
