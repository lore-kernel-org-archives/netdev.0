From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: Extend irq_set_affinity_notifier() to use a call chain
Date: Tue, 27 May 2014 12:10:29 +0200 (CEST)
Message-ID: <alpine.DEB.2.02.1405271202000.21720@ionos.tec.linutronix.de>
References: <5381DEDC.8050204@gmail.com> <alpine.DEB.2.02.1405261313570.21720@ionos.tec.linutronix.de> <53832472.7070000@gmail.com> <alpine.DEB.2.02.1405261327500.21720@ionos.tec.linutronix.de> <53832D28.1050207@mellanox.com>
 <alpine.DEB.2.02.1405261412110.21720@ionos.tec.linutronix.de> <5384498A.9080900@mellanox.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Ben Hutchings <ben@decadent.org.uk>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>, idos@mellanox.com,
	Yevgeny Petrilin <yevgenyp@mellanox.com>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:52642 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751884AbaE0KKS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2014 06:10:18 -0400
In-Reply-To: <5384498A.9080900@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 27 May 2014, Amir Vadai wrote:
> On 5/26/2014 3:39 PM, Thomas Gleixner wrote:
> > Even if you'd solve that and have a callback in the driver, then the
> > callback never can restart the napi session directly. All it can do is
> > set a flag which needs to be checked in the RX path, right?
> > 
> > So what's the point of adding notifier call chain complexity, ordering
> > problems etc., if you can simply note the fact that the affinity
> > changed in the rmap itself and check that in the RX path?
> 
> I will try to find a solution in the spirit of what you suggested -
> to let the rmap library notify napi about affinity changes - without
> adding this complexity to the code.

I'd rather avoid the term "notify". Because it's not an active
notification which results in an immediate NAPI restart. NAPI has to
poll the information in rmap or wherever you end up storing it.

Thanks,

	tglx
