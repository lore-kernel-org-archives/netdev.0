From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: loosing connections on bridge topology changes
Date: Wed, 13 May 2009 10:44:49 -0700
Message-ID: <20090513104449.49b1df6a@nehalam>
References: <4A0AE3A5.20100@hiramoto.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Karl Hiramoto <karl@hiramoto.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:43944 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755090AbZEMRoy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 May 2009 13:44:54 -0400
In-Reply-To: <4A0AE3A5.20100@hiramoto.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 13 May 2009 17:13:41 +0200
Karl Hiramoto <karl@hiramoto.org> wrote:

> 
> Hi,
> 
> I have a user space application, that puts eth0 into bridge br0.  At 
> this moment all connections seem frozen. Telnet, HTTP, and NFS.
> 
> For development i have nfs root fs.
> 
> There is a ioctl() that does the equivalent of "brctl addif br0 eth0"
> 
> That cuts all the connections for a few seconds.
> 
> nfs: server 192.168.10.51 not responding, still trying
> br0: topology change detected, propagating           
> br0: port 1(eth0) entering forwarding state          
> nfs: server 192.168.10.51 not responding, still trying
> nfs: server 192.168.10.51 OK                         
> nfs: server 192.168.10.51 OK  
> 
> 
> Then everything is OK..
> 
> Is there anyway i can fix this, so my applicaion goes ahead at full speed?
> 
> 
> using libnl i tried flushing the ARP cache on all devices, but it didn't 
> seem to help.
> 
> 
> Thanks
> --
> 
> Karl.

turn off forwarding delay (unless you are using STP).
 brctl setfd br0 0

-- 
