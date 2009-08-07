From: Brice Goglin <Brice.Goglin@inria.fr>
Subject: Re: Receive side performance issue with multi-10-GigE and NUMA
Date: Fri, 07 Aug 2009 23:18:12 +0200
Message-ID: <4A7C9A14.7070600@inria.fr>
References: <20090807170600.9a2eff2e.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Network Developers <netdev@vger.kernel.org>,
	Yinghai Lu <yhlu.kernel@gmail.com>, gallatin@myri.com
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3-relais-sop.national.inria.fr ([192.134.164.104]:5006 "EHLO
	mail3-relais-sop.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753142AbZHGVSA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Aug 2009 17:18:00 -0400
In-Reply-To: <20090807170600.9a2eff2e.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bill Fink wrote:
> This could be because I discovered that if I did:
>
> 	find /sys -name numa_node -exec grep . {} /dev/null \;
>
> that the numa_node associated with all the PCI devices was always 0,
> and if IIUC then I believe some of the PCI devices should have been
> associated with NUMA node 2.  Perhaps this is what is causing all
> the memory pages allocated by the myri10ge driver to be on NUMA
> node 0, and thus causing the major performance issue.
>   

I've seen some cases in the past where numa_node was always 0 on
quad-Opteron machines with a PCI bus on node 1. IIRC it got fixed in
later kernels thanks to patches from Yinghai Lu (CC'ed).
Is the corresponding local_cpus sysfs file wrong as well ?
Maybe your kernel doesn't properly handle the NUMA location of PCI
devices on Nehalem machines yet?

Brice

