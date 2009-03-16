From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: Intel 82567LM e1000e DHCP problem/question
Date: Mon, 16 Mar 2009 11:38:49 -0700 (Pacific Daylight Time)
Message-ID: <alpine.WNT.2.00.0903161133100.5116@jbrandeb-desk1.amr.corp.intel.com>
References: <BAY143-W41A6A9A51EDB64905CA4D1B99A0@phx.gbl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	e1000-devel@lists.sourceforge.net
To: Pelle Svensson <pelle2004@hotmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:26712 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753514AbZCPSiw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Mar 2009 14:38:52 -0400
In-Reply-To: <BAY143-W41A6A9A51EDB64905CA4D1B99A0@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

good idea to include e1000-devel@lists.sourceforge.net on these kinds of 
requests.


On Sun, 15 Mar 2009, Pelle Svensson wrote:
> Is there any functionality inside the driver for DHCP request.
> I see in the source that there is some kind of DHCP filter f the tx stream.
> Can the drive issue DHCP request inside it self when the Cable is unplugged/plugged.

short answer, the driver no, but the management firmware, maybe.
 
> I'm tracing a DHCP fault. 

what kind of fault?  Is the server faulting?

> When the net is brought down, ifdown eth0, the dhclient is killed.
> Then when I unplugged/plugged the cable I get a DHCP request even that 
> dhclient is down.
> 
> Also the Wireshark format of the DHCP request are different.
> Correct request includes from dhclient has:
> > Option: (t=12,l=5) Host Name = "pc005"
> Incorrect requests when dhclient is killed does not have above.

you apparently have the Intel AMT firmware (ME aka Management Engine) 
enabled in your BIOS, you can try to configure it by hitting CTRL-P during 
post (pre-boot) or at the prompt where it says to hit CTRL-P to enter 
system management setup.

The ME (management engine) firmware is trying to acquire its own dhcp 
address and will do so if the driver is either not loaded or not up.

Once the driver is loaded the firmware may still try to acquire a second 
dhcp address for the ME, depending on your configuration.  This whole 
setup works a lot like IPMI, but generally the ME is not configurable via 
IPMI interfaces.

Hope this helps,
  Jesse
