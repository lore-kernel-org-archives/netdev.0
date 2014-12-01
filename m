From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: net-PA Semi: Deletion of unnecessary checks before the function
 call "pci_dev_put"
Date: Mon, 01 Dec 2014 21:29:05 +0100
Message-ID: <1417465745.28610.0.camel@sipsolutions.net>
References: <5307CAA2.8060406@users.sourceforge.net>
	 <alpine.DEB.2.02.1402212321410.2043@localhost6.localdomain6>
	 <530A086E.8010901@users.sourceforge.net>
	 <alpine.DEB.2.02.1402231635510.1985@localhost6.localdomain6>
	 <530A72AA.3000601@users.sourceforge.net>
	 <alpine.DEB.2.02.1402240658210.2090@localhost6.localdomain6>
	 <530B5FB6.6010207@users.sourceforge.net>
	 <alpine.DEB.2.10.1402241710370.2074@hadrien>
	 <530C5E18.1020800@users.sourceforge.net>
	 <alpine.DEB.2.10.1402251014170.2080@hadrien>
	 <530CD2C4.4050903@users.sourceforge.net>
	 <alpine.DEB.2.10.1402251840450.7035@hadrien>
	 <530CF8FF.8080600@users.sourceforge.net>
	 <alpine.DEB.2.02.1402252117150.2047@localhost6.localdomain6>
	 <530DD06F.4090703@users.sourceforge.net>
	 <alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6>
	 <5317A59D.4@users.sourceforge.net> <547A09B1.9090102@users.sourceforge.net>
	 <547B579F.10709@gmx.de> <547BC5AD.6090500@users.sourceforge.net>
	 (sfid-20141201_023451_153915_6CFB474F)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Lino Sanfilippo <LinoSanfilippo@gmx.de>,
	Olof Johansson <olof@lixom.net>, netdev@vger.kernel.org,
	backports@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>,
	"Luis R. Rodriguez" <mcgrof@suse.com>
To: SF Markus Elfring <elfring@users.sourceforge.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:60008 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932158AbaLAU3S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Dec 2014 15:29:18 -0500
In-Reply-To: <547BC5AD.6090500@users.sourceforge.net> (sfid-20141201_023451_153915_6CFB474F)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-12-01 at 02:34 +0100, SF Markus Elfring wrote:

> > Some of those NULL pointer checks on input parameters may have been
> > added subsequently to functions. So there may be older kernel versions
> > out there in which those checks dont exists in some cases. If some of
> > the now "cleaned up" code is backported to such a kernel chances are
> > good that those missing checks are overseen. And then neither caller nor
> > callee is doing the NULL pointer check.

> I assume that a few backporters can tell you more about their corresponding
> software development experiences.
> http://www.do-not-panic.com/2014/04/automatic-linux-kernel-backporting-with-coccinelle.html

In such cases we just provide an appropriate wrapper and replace callers
of the original function by callers of the wrapper, typically with a
#define.

So this kind of evolution is no problem for the (automated) backports
using the backports project - although it can be difficult to detect
such a thing is needed.

johannes
