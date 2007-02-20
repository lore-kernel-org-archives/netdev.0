From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: all syscalls initially taking 4usec on a P4? Re: nonblocking UDPv4 recvfrom() taking 4usec @ 3GHz?
Date: Tue, 20 Feb 2007 21:48:59 +0300
Message-ID: <20070220184859.GA1949@2ka.mipt.ru>
References: <20070219231447.GA4400@outpost.ds9a.nl> <p73d545drx6.fsf@bingen.suse.de> <20070220162714.GA3245@outpost.ds9a.nl> <20070220164124.GA24930@2ka.mipt.ru> <20070220184242.GA30077@filer.fsl.cs.sunysb.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: bert hubert <bert.hubert@netherlabs.nl>,
	Andi Kleen <andi@firstfloor.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Josef Sipek <jsipek@fsl.cs.sunysb.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:36275 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030355AbXBTStM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Feb 2007 13:49:12 -0500
Content-Disposition: inline
In-Reply-To: <20070220184242.GA30077@filer.fsl.cs.sunysb.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 20, 2007 at 01:42:42PM -0500, Josef Sipek (jsipek@fsl.cs.sunysb.edu) wrote:
> A better thing would be to use getuid - it turns into just a return with a
> memory dereference). I ran it on my 3.06GHz P4 (HT, but only UP kernel),
> PREEMPT, HZ=1000...
> 
> 3.290196 0.470588 0.402614 0.396078 0.393464 0.396078 0.386928 0.386928 0.386928 0.386928
> 0.386928 0.386928 0.386928 0.386928 0.386928 0.386928 0.386928 0.386928 0.386928 0.386928
> 0.386928 0.386928 0.386928 0.386928 0.386928 0.386928 0.386928 0.386928 0.386928 0.386928
> 0.386928 0.386928 0.386928 0.386928 0.386928 0.386928 0.386928 0.386928 0.386928 0.386928

I got following.

delta for syscall: 9112 cycles = 2.977778 us
delta for syscall: 1224 cycles = 0.400000 us
delta for syscall: 1071 cycles = 0.350000 us
delta for syscall: 1054 cycles = 0.344444 us
delta for syscall: 1054 cycles = 0.344444 us

Likely first overhead related to cache population or gamma-ray radiation.
If it happens only one (it does in my test), then everything is ok I
think. Bert, how frequently you get that long recvfrom()?

-- 
	Evgeniy Polyakov
