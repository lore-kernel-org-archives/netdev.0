From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: Unexcepted latency (order of 100-200 ms) with TCP (packet receive)
Date: Fri, 27 Apr 2007 18:07:11 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0704271122230.28337@kivilampi-30.cs.helsinki.fi>
References: <Pine.LNX.4.64.0704241518370.28337@kivilampi-30.cs.helsinki.fi>
 <4630D069.30605@redhat.com> <Pine.LNX.4.64.0704262219200.18515@kivilampi-30.cs.helsinki.fi>
 <20070427031757.513f6ad7.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696243703-1028982146-1177662163=:28337"
Cc: Chuck Ebbert <cebbert@redhat.com>, Netdev <netdev@vger.kernel.org>
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:48293 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755966AbXD0PHO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Apr 2007 11:07:14 -0400
In-Reply-To: <20070427031757.513f6ad7.billfink@mindspring.com>
Content-ID: <Pine.LNX.4.64.0704271750210.6246@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1028982146-1177662163=:28337
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0704271153361.28337@kivilampi-30.cs.helsinki.fi>

On Fri, 27 Apr 2007, Bill Fink wrote:

> On Thu, 26 Apr 2007, Ilpo Järvinen wrote:
> 
> > On Thu, 26 Apr 2007, Chuck Ebbert wrote:
> > 
> > > Ilpo Järvinen wrote:
> > > > ...I'm unsure how to continue the investigation from this point onward 
> > > > and asking for ideas/suggestions or how to rule out more possibilities... 
> > > > Or is there some knob which I don't know of that should be toggled or 
> > > > something, is 2.6 network stack expected to behave this way?
> > > > 
> > > 
> > > Try a different network adapter.
> > 
> > Hmm, I thought I had already done this but I just noticed that it is so 
> > that the adapter was still the same as the other host has two adapter (now 
> > that I look again). I'll give it a try tomorrow to see if using the 
> > another adapter makes any difference.

...Much more promising result this time. I noticed that there was another 
eth hw on mainboard, thus my previous test with different hw was not 
valid as I assumed "wrong" (didn't even notice the other) one to be eth0:

02:05.0 Ethernet controller: 3Com Corporation 3c905C-TX/TX-M [Tornado] (rev 74)
02:08.0 Ethernet controller: Intel Corporation 82801DB PRO/100 VE (LOM) Ethernet Controller (rev 82)

With 3c905 I have the problem, with Intel one it does not show up 
(tested today).

> > > Try turning off hardware TSO offload:
> > >   ethtool -K ethX tso off
> > 
> > # ethtool -K eth0 tso off
> > Cannot set device tcp segmentation offload settings: Operation not 
> > supported
> 
> Could the delays be caused by Ethernet PAUSE frames (which might not
> be rquired at the slower 10FD but might at 100)?  TX and RX pause
> control settings (check with "ethtool -a") might be different between
> the 2.4 and 2.6 kernels.

# ethtool -a eth0
Pause parameters for eth0:
Cannot get device pause settings: Operation not supported


> Also check things like net.core.netdev_max_backlog and ifconfig
> txqueuelen settings. 

# cat /proc/sys/net/core/netdev_max_backlog 
1000

...and...

txqueuelen:1000

> And check "ethtool -S", "netstat -s", and ifconfig error counters.

Nothigh really alarming was found, errors were all zero, only thing that 
could be even remotely interesting is this:
    5 delayed acks further delayed because of locked socket


-- 
 i.
---696243703-1028982146-1177662163=:28337--
