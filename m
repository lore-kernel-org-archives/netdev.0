From: Sven-Haegar Koch <haegar@sdinet.de>
Subject: Re: Bridge stays down until a port is added
Date: Fri, 12 Aug 2011 14:22:27 +0200 (CEST)
Message-ID: <alpine.DEB.2.02.1108121418090.11637@aurora>
References: <20110811070659.GA21307@torres.zugschlus.de> <20110811081706.7307e8b2@nehalam.ftrdhcpuser.net> <20110811205429.GB21307@torres.zugschlus.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
To: Marc Haber <mh+netdev@zugschlus.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.sdinet.de ([78.47.32.153]:37175 "EHLO mail.sdinet.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751130Ab1HLM3w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Aug 2011 08:29:52 -0400
In-Reply-To: <20110811205429.GB21307@torres.zugschlus.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 11 Aug 2011, Marc Haber wrote:

> On Thu, Aug 11, 2011 at 08:17:06AM -0700, Stephen Hemminger wrote:
> > On Thu, 11 Aug 2011 09:06:59 +0200
> > Marc Haber <mh+netdev@zugschlus.de> wrote:
> > > Is that a feature? If so, why does the interface stay pingable after
> > > removing the dummy0 interface from the bridge?
> > 
> > Yes, there are no links to send a packet so it seems logical
> > that there would be no carrier.
> 
> Yes, but if I can configure an IP address to the bridge I would expect
> it to be reachable even if there are no interfaces in the bridge.
> "Older" kernels used to behave like that.

For me (using kernel 3.0.0) it seems to work as I expect it:

aurora:~# brctl addbr br0
aurora:~# ifconfig br0 192.168.254.1 netmask 255.255.255.0 up
aurora:~# ping 192.168.254.1
PING 192.168.254.1 (192.168.254.1) 56(84) bytes of data.
64 bytes from 192.168.254.1: icmp_req=1 ttl=64 time=0.087 ms

aurora:~# ifconfig br0
br0       Link encap:Ethernet  HWaddr 96:e1:ba:9f:91:f9  
          inet addr:192.168.254.1  Bcast:192.168.254.255  Mask:255.255.255.0
          UP BROADCAST MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

The br0 interface has no carrier / is not "running", exactly like an 
ethernet port without a cable.

c'ya
sven-haegar

-- 
Three may keep a secret, if two of them are dead.
- Ben F.
