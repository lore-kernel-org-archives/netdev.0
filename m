From: Kyle Moffett <mrmacman_g4@mac.com>
Subject: Re: PM policy, hotplug, power saving (was Re: [PATCH] b44: power down PHY when interface down)
Date: Sun, 1 Jul 2007 00:51:15 -0400
Message-ID: <05EEFFFE-AD93-40A1-8851-92C3053286E1@mac.com>
References: <4354d3270706300447ladcda4by987b1f87963112f9@mail.gmail.com> <20070630120541.GA21339@srcf.ucam.org> <46866C6B.9010801@linux.intel.com> <468687DE.6030003@garzik.org>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Arjan van de Ven <arjan@linux.intel.com>,
	Matthew Garrett <mjg59@srcf.ucam.org>,
	=?ISO-8859-1?Q?T=F6r=F6k_Edvin?= <edwintorok@gmail.com>,
	netdev@vger.kernel.org, power@bughost.org, zambrano@broadcom.com,
	linux-kernel@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpout.mac.com ([17.250.248.174]:64898 "EHLO smtpout.mac.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750772AbXGAEvX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Jul 2007 00:51:23 -0400
In-Reply-To: <468687DE.6030003@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Jun 30, 2007, at 12:42:06, Jeff Garzik wrote:
> Definitely matters.  Switch renegotiation can take a while, and you  
> must take into account the common case of interface bouncing  
> (immediate down, then up).
>
> Hoards actively complained the few times we experimented with this,  
> because of e.g. DHCP's habit of bouncing the interface, which  
> resulted in PHY power bouncing, which resulted in negotiation,  
> which resulted in an excrutiating wait on various broken or stupid  
> switches.
>
> Overall, this may be classed with other problems of a similar  
> sort:  we can power down a PHY, but that removes hotplug capability  
> and extends partner/link negotiation time.
>
> Like SATA, we actually want to support BOTH -- active hotplug and  
> PHY power-down -- and so this wanders into power management policy.
>
> Give me a knob, and we can program plenty of ethernet|SATA|USB|...  
> drivers to power down the PHY and save power.

With some buggy switches and other hardware you actually *want* to  
bounce the link to get them to properly renegotiate.  I can also see  
wanting to power off and on a single-PoE-port NIC to restart whatever  
device is at the other end, although I don't know if any such devices  
exist.  Currently the tg3 driver turns the PHY off and on during down/ 
up on a few of my systems, which I use to make a buggy no-name switch  
recognize STP changes properly.

Cheers,
Kyle Moffett
