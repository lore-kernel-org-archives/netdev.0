From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Network problem with bridge and virtualbox
Date: Fri, 30 Sep 2011 17:18:39 -0700
Message-ID: <20110930171839.2893bfa6@nehalam.linuxnetplumber.net>
References: <20110929124941.GA16567@electro-mechanical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: William Thompson <wt@electro-mechanical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:38088 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753808Ab1JAASm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Sep 2011 20:18:42 -0400
In-Reply-To: <20110929124941.GA16567@electro-mechanical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 29 Sep 2011 08:49:41 -0400
William Thompson <wt@electro-mechanical.com> wrote:

> Please keep me in the CC as I am not subscribed.
> 
> I'm using a 64-bit kernel 3.0.0 and virtualbox 4.1.2.
> 
> My problem is that I cannot ping the host from a virtual machine.
> 
> My bridge is configured as follows:
> # brctl addbr br0
> # brctl setfd br0 0
> # brctl stp br0 off
> # ifconfig br0 10.2.3.1 netmask 255.255.255.0
> 
> In the virtual machine, it is set to use br0 as it's interface (bridge mode)
> and it's IP is 10.2.3.10.
> 
> The host gets packets from the vm, but the vm does not receive packets back. 
> 
> I have this same setup working on a 32-bit kernel 2.6.38.6 on another
> machine with virtualbox 4.0.4.
> 
> I had a thought that the bridge on the host wasn't responding due to having
> no ports configured so I added one of my spare ethernet cards to it as
> follows:
> # brctl addif br0 eth1
> # ifconfig eth1 up
> 
> The card was plugged into a switch.  After doing this, the vm still could not
> talk to the host.  I added a physical machine to the switch that eth1 was
> connected to and configured it to 10.2.3.2.  I was able to ping 10.2.3.2 but
> not 10.2.3.1

Did you add any interface to the bridge?
I think you were bit by the change in carrier behavior. No carrier on the
bridge interface tracks the union of the devices in the bridge.
Several people have been using bridge in strange way (as a dummy device)
with no physical interfaces and some applications are checking for carrier.
