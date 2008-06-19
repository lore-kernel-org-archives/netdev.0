From: Nicolas Pitre <nico@cam.org>
Subject: Re: [PATCH 6/8]  pxa: make lubbock to use smc91x platform data
Date: Thu, 19 Jun 2008 12:53:49 -0400 (EDT)
Message-ID: <alpine.LFD.1.10.0806191243400.2982@xanadu.home>
References: <485A3E4A.6070706@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: linux-netdev <netdev@vger.kernel.org>,
	linux-arm-kernel <linux-arm-kernel@lists.arm.linux.org.uk>,
	Magnus Damm <magnus.damm@gmail.com>
To: Eric Miao <eric.y.miao@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relais.videotron.ca ([24.201.245.36]:52557 "EHLO
	relais.videotron.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751240AbYFSQy0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2008 12:54:26 -0400
Received: from xanadu.home ([66.131.194.97]) by VL-MH-MR002.ip.videotron.ca
 (Sun Java(tm) System Messaging Server 6.3-4.01 (built Aug  3 2007; 32bit))
 with ESMTP id <0K2P00F01YXP8UT0@VL-MH-MR002.ip.videotron.ca> for
 netdev@vger.kernel.org; Thu, 19 Jun 2008 12:53:49 -0400 (EDT)
In-reply-to: <485A3E4A.6070706@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 19 Jun 2008, Eric Miao wrote:

> 
> Signed-off-by: Eric Miao <eric.miao@marvell.com>

This (and 7/8 and 8/8) are a bit unfortunate.  Maybe not as visible on 
Lubbock which has a SMC91C94 which can do 10mbps only, but the others 
will have poorer performances because of those patches.  Did you compare 
performances, let's say with netperf, before and after those patches are 
applied?

I understand your goal of wanting to have a single kernel image that 
dynamically can select the right bus access method for all the concerned 
platforms.  But I think you'll see that the runtime overhead has a 
significant impact on network throughput and CPU usage.

I think that some other solution should be explored such that when only 
one machine type (or machine types with the same bus config) is 
configured then the compile time optimizations should remain.  Something 
based on the machine_is_lubbock(), machine_is_Mainstone(), and so on, 
which becomes constants with the right kernel configuration.


Nicolas
