From: James Feeney <james@nurealm.net>
Subject: Re: r8169 - it's dead jim
Date: Wed, 27 Nov 2013 21:02:58 -0700
Message-ID: <5296C072.4070000@nurealm.net>
References: <529105F8.9030901@nurealm.net> <20131124005022.GA6299@electric-eye.fr.zoreil.com>
Reply-To: james@nurealm.net
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Realtek and the Linux r8169 crew <netdev@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay-fo.embarq.synacor.com ([208.47.184.9]:59444 "EHLO
	mailrelay.embarq.synacor.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755928Ab3K1EDB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Nov 2013 23:03:01 -0500
In-Reply-To: <20131124005022.GA6299@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Francois

> Which one exactly ?

Sorry - just based upon a Google search, this problem with the card not
recognizing that a cable has been plugged into the interface, seems to have come
up off and on for a while, many years.

> blah ?

"<blah>" - referring to the network interface name, in my case "enp22s0".  This
interface is a Netgear "Gigabit PC Card", model GA511, into a Thinkpad T60,
acting as a router.

> The r8169 driver is the same in v3.12 and v3.12.1. Either some userspace
> application works in your back or your device experienced a runtime
> suspend / resume cycle where it previously didn't.

That would seem to make sense.  After some more problems with the interface, I
later noticed that having the card come-up at 1000Mb/s and Full duplex was not
enough to indicate that the card was working.  When the interface was just
handling ping packets it seemed to work fine.  But then, whenever there was a
file transfer - downloading some email or a large file, for instance - the
interface seems to "choke".  Watching a repeated "ethtool enp22s0", the link
speed and duplex would change constantly, dropping down to 10Mb/s and Half
duplex, then up to 100Mb/s and Full duplex, than back down.  If the file
transfers were halted, so that nothing more than ping was going through the
interface, the speed and duplex would come back up, to 1000Mb/s and Full duplex.
 Practically, the interface was unusable, and I swapped-out the card for an
Intel Pro 100, which works fine.   So the problem would then seem to have
nothing to do with the PC Card hardware on the Thinkpad.

> What do you want exactly ? 10 Mb/s, 100 Mb/s ? Limited / no advertising ?

Well, according to "ethtool", the card advertises up to 1000Mb/s, Full duplex,
and Auto-negotiation.  It just seems that it should not constantly try to
re-configure itself.  I have not studied the code to find-out what would trigger
a re-negotiation, or trigger a suspend/resume.

> The patch is badly broken.

Sorry - I haven't tried to re-compile the driver, since it was easier to just
swap-out the card, for another with a different driver.

Maybe there is a simple way to modify the driver to "lock" the configuration?
Or ... ?

If you have another patch, I can plug the card back in and try it out.


Thanks

James
