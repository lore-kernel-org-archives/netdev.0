From: William Thompson <wt@electro-mechanical.com>
Subject: Re: Network problem with bridge and virtualbox
Date: Mon, 3 Oct 2011 07:30:44 -0400
Message-ID: <20111003113044.GR19871@electro-mechanical.com>
References: <20110929124941.GA16567@electro-mechanical.com>
 <20110930171839.2893bfa6@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.electro-mechanical.com ([216.184.71.30]:57843 "EHLO
	mail.electro-mechanical.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755084Ab1JCLau (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Oct 2011 07:30:50 -0400
Content-Disposition: inline
In-Reply-To: <20110930171839.2893bfa6@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 30, 2011 at 05:18:39PM -0700, Stephen Hemminger wrote:
> On Thu, 29 Sep 2011 08:49:41 -0400
> William Thompson <wt@electro-mechanical.com> wrote:
> 
> > Please keep me in the CC as I am not subscribed.
> > 
> > I'm using a 64-bit kernel 3.0.0 and virtualbox 4.1.2.
> > 
> > My problem is that I cannot ping the host from a virtual machine.
> > 
> > My bridge is configured as follows:
> > # brctl addbr br0
> > # brctl setfd br0 0
> > # brctl stp br0 off
> > # ifconfig br0 10.2.3.1 netmask 255.255.255.0
> > 
> > In the virtual machine, it is set to use br0 as it's interface (bridge mode)
> > and it's IP is 10.2.3.10.
> > 
> > The host gets packets from the vm, but the vm does not receive packets back. 
> > 
> > I have this same setup working on a 32-bit kernel 2.6.38.6 on another
> > machine with virtualbox 4.0.4.
> > 
> > I had a thought that the bridge on the host wasn't responding due to having
> > no ports configured so I added one of my spare ethernet cards to it as
> > follows:
> > # brctl addif br0 eth1
> > # ifconfig eth1 up
> > 
> > The card was plugged into a switch.  After doing this, the vm still could not
> > talk to the host.  I added a physical machine to the switch that eth1 was
> > connected to and configured it to 10.2.3.2.  I was able to ping 10.2.3.2 but
> > not 10.2.3.1
> 
> Did you add any interface to the bridge?

Initially, no.

> I think you were bit by the change in carrier behavior. No carrier on the
> bridge interface tracks the union of the devices in the bridge.
> Several people have been using bridge in strange way (as a dummy device)
> with no physical interfaces and some applications are checking for carrier.

That's how I have been using it.

Using it as a dummy, ie no interfaces added to the bridge, on 3.0.0 I was
unable to communicate with the host from the VM.  I added eth1 to it.  This
has a link to a physical network.  I assigned IPs to the host and the VM to
be on the same network that eth1 was attached.  From the VM I could
communicate with devices on the physical network but not the host.  The host
could also communicate with the other devices.
