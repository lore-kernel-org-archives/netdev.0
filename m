From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [RFC 0/5] bridge - introduce via_phys_dev feature
Date: Fri, 26 Feb 2010 08:18:43 -0800
Message-ID: <20100226081843.07f37742@nehalam>
References: <20090511114639.440944109@openvz.org>
	<20090519152153.012d4814@nehalam>
	<20090520192726.GF4968@lenovo>
	<20090520131225.03b7715a@nehalam>
	<20090521180805.GC4932@lenovo>
	<20090521140504.1865883b@nehalam>
	<20090522201850.GF5354@lenovo>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bridge@linux-foundation.org, netdev@vger.kernel.org
To: Cyrill Gorcunov <gorcunov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:59603 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S965238Ab0BZQSx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 11:18:53 -0500
In-Reply-To: <20090522201850.GF5354@lenovo>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Looking back at this. What if the API was simpler:

Instead of:
> Typical session looks like
> 
> | s...@10.10.0.160$ brctl addbr br0
> | s...@10.10.0.160$ ifconfig br0 up
> | s...@10.10.0.160$ echo 1 > /sys/class/net/bridge/br0/via_phys_dev
> | s...@10.10.0.160$ brctl addif br0 eth0
> | (...waiting a bit...)
> | s...@10.10.0.160$

Why not:
  1. Setup bridge (and any other interfaces except eth0); includes bringing br0 up
  2. Add eth0 to bridge with new flag to inherit
       a. brctl addif br0 eth0 inherit

Inherit functionality would need to move address (Ether, IP, IPv6)
and routes from eth0 to br0.
I will see about doing it as much as possible in userspace.
