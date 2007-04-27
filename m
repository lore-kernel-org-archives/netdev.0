From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: wrong destination MAC in ethernet packets from sky2 ?
Date: Fri, 27 Apr 2007 11:14:10 -0700
Message-ID: <20070427111410.6f62cceb@freekitty>
References: <7B293F8C16516D4B89341C937F15F0B50E3576@uniweb.united-consult.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <sk-drivers@lists.linux-foundation.org>, <netdev@vger.kernel.org>
To: "Csillag Kristof" <Csillag.Kristof.ext@united-consult.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:44456 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754314AbXD0SOy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Apr 2007 14:14:54 -0400
In-Reply-To: <7B293F8C16516D4B89341C937F15F0B50E3576@uniweb.united-consult.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 27 Apr 2007 11:33:18 +0200
"Csillag Kristof" <Csillag.Kristof.ext@united-consult.hu> wrote:

> Hi all!
> 
> I have encountered a strange error, and I believe that
> the culprit might be the sky2 driver, so I hope you can help.
> 
> The symptom is that sometimes the connection between my server box
> (which is based on a Foxconn g9657ma motherboard
> (which contains a "Yukon-EC Ultra (0xb4) rev 2" gigabit network adapter
> - 11ab:4364)) and the rest of the network gets ... screwed up.

That is the chip on Gigabyte motherboard that was so busted, I ended up
blacklisting it for 2.6.21. Please send full lspci -vvx for the motherboard


> Some things work, and some don't.
> Server can ping the client, but the client can not ping the server.
> An other client can not get a DHCP address.
> 
> From the logs, I can see that the server _thinks_ that it has sent back
> some DHCP offers, but the client never received any.
> 

The 88e8056 is sensitive to PCI timing issues. Not sure what is going on yet,
but for some reason it works on Asus, but on Gigabyte it shows all the signs
of not reading memory correctly, or doing out of order stuff.

Since I don't work for a hardware company and don't have all the bus
analyzer hooks to see what really is going on, it probably won't get fixed
fast.

That is why the 88e8056 is marked 'ifdef broken' until this is figured out.


> 
> Since I ruled out any other software obstacles, I have done a network
> traffic capture (with wireshark) on both ends, and here is what I have found:
> 
> - On the client end, it seems that the DHCP OFFER package was addressed to a 
>   different MAC address, not the one the DHCP DISCOVER originated from.
>   More precisely, the first two bytes of the six-byte MAX address is different,
>   and the last four byte matches.
> 
> - Looking at the same traffic on the server side, it seems that the destination
>   MAC address is OK.
> 
> - To decide which side is right, I have done a capture on a third machine.
>   (I can do this, thanks to a dump hub and promiscuous mode.)
>   It verified that the MAC address in the DHCP OFFER is indeed different.
>   
> So, it looks like sometimes the first two bytes of the destination MAC address
> is screwed up in the ethernet packets coming out from my server.
> 
>    * * *
> 
> I am using debian 2.6.20-2 kernel, which is based on 2.6.20.7.
> The version of the sky2 driver is 1.10.
> 
> Since I suspected that this might be a driver error, I took the 1.13 version
> from 2.6.21-rc7, and "backported" it to my current kernel.
> (I had to comment out some vlan-specific parts, but I do not care for that
> now.)
> 
> So now I am running sky2 v1.13, but the same error is still present.
> 
> It is important to note that this error does not always occur.
> Sometime everything is all right, sometime messages just stop
> getting through.
> 
> Unloading and reloading the sky2 module sometimes help.
> 
  * * *
> 
> Do you have any idea what can the root cause for this possibly be,
> or (more importantly) how can I fix this?
> This box is mission-critical to me.
> 
> Thank you for your help:
> 
>       Kristof Csillag

Are you using jumbo frames? probably not.

The driver in 2.6.21 enables store/forward on transmit and earlier drivers
did not.  Store/forward should help performance and eliminate any possible
bus latency issues.


-- 
Stephen Hemminger <shemminger@linux-foundation.org>
