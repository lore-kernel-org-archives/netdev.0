From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: net/ipv4/ipconfig.c:1590:2: error: implicit declaration of
 function 'ic_nameservers_predef'
Date: Tue, 2 Oct 2012 16:54:09 +0800
Message-ID: <20121002085409.GB25630@localhost>
References: <20121002032744.GA11811@localhost>
 <CAKoUArkDK8sQ=DRgrPhEnnWPsdMkgNtZE6S2o5rx6tXhfB3SsA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Fritz <chf.fritz@googlemail.com>,
	kernel-janitors@vger.kernel.org, netdev@vger.kernel.org,
	andriy.shevchenko@linux.intel.com
To: Rami Rosen <roszenrami@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:10411 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753327Ab2JBIyl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Oct 2012 04:54:41 -0400
Content-Disposition: inline
In-Reply-To: <CAKoUArkDK8sQ=DRgrPhEnnWPsdMkgNtZE6S2o5rx6tXhfB3SsA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 02, 2012 at 08:24:05AM +0200, Rami Rosen wrote:
> Hi,
> commit 842b08bbee448b2069aaebb7f18b40942ad2a1bd
> fixes it.
> 
> git show 842b08bbee448b2069aaebb7f18b40942ad2a1bd
> 
> commit 842b08bbee448b2069aaebb7f18b40942ad2a1bd
> 
> Author: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
> Date:   Mon Sep 24 22:09:58 2012 +0000
> 
>     ipconfig: fix trivial build error
> 
>     The commit 5e953778a2aab04929a5e7b69f53dc26e39b079e ("ipconfig: add nameserv
>     IPs to kernel-parameter ip=") introduces ic_nameservers_predef() that define
>     only for BOOTP. However it is used by ip_auto_config_setup() as well. This
>     patch moves it outside of #ifdef BOOTP.

Sorry, I get this bug while doing bisectibility tests on the linux-can
tree.  Obviously I should not count the net tree's commits as part of
the linux-can tree. Fixed.

Thanks,
Fengguang

> On Tue, Oct 2, 2012 at 5:27 AM, Fengguang Wu <fengguang.wu@intel.com> wrote:
> > Hi Christoph,
> >
> > FYI, kernel build failed on
> >
> > commit: 5e953778a2aab04929a5e7b69f53dc26e39b079e ipconfig: add nameserver IPs to kernel-parameter ip=
> > config: i386-randconfig-b106 (attached as .config)
> >
> > All error/warnings:
> >
> > net/ipv4/ipconfig.c: In function 'ip_auto_config_setup':
> > net/ipv4/ipconfig.c:1590:2: error: implicit declaration of function 'ic_nameservers_predef' [-Werror=implicit-function-declaration]
> > cc1: some warnings being treated as errors
> >
> > vim +1590 net/ipv4/ipconfig.c
> >
> > 92ffb85d (Amos Waterland  2008-01-05  1578)      */
> > ^1da177e (Linus Torvalds  2005-04-16  1579)     if (ic_proto_name(addrs))
> > ^1da177e (Linus Torvalds  2005-04-16  1580)             return 1;
> > ^1da177e (Linus Torvalds  2005-04-16  1581)
> > 92ffb85d (Amos Waterland  2008-01-05  1582)     /* If no static IP is given, turn off autoconfig and bail.  */
> > 92ffb85d (Amos Waterland  2008-01-05  1583)     if (*addrs == 0 ||
> > 92ffb85d (Amos Waterland  2008-01-05  1584)         strcmp(addrs, "off") == 0 ||
> > 92ffb85d (Amos Waterland  2008-01-05  1585)         strcmp(addrs, "none") == 0) {
> > 92ffb85d (Amos Waterland  2008-01-05  1586)             ic_enable = 0;
> > 92ffb85d (Amos Waterland  2008-01-05  1587)             return 1;
> > 92ffb85d (Amos Waterland  2008-01-05  1588)     }
> > 92ffb85d (Amos Waterland  2008-01-05  1589)
> > 5e953778 (Christoph Fritz 2012-09-21 @1590)     ic_nameservers_predef();
> > 5e953778 (Christoph Fritz 2012-09-21  1591)
> > 92ffb85d (Amos Waterland  2008-01-05  1592)     /* Parse string for static IP assignment.  */
> > ^1da177e (Linus Torvalds  2005-04-16  1593)     ip = addrs;
> > ^1da177e (Linus Torvalds  2005-04-16  1594)     while (ip && *ip) {
> > ^1da177e (Linus Torvalds  2005-04-16  1595)             if ((cp = strchr(ip, ':')))
> > ^1da177e (Linus Torvalds  2005-04-16  1596)                     *cp++ = '\0';
> >
> > ---
> > 0-DAY kernel build testing backend         Open Source Technology Centre
> > Fengguang Wu, Yuanhan Liu                              Intel Corporation
