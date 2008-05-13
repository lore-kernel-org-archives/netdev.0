From: Ack <ackman@gtf.org>
Subject: Re: RTL8169 driver no longer functioning with 8111b
Date: Tue, 13 May 2008 18:29:44 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0805131821500.2988@havoc.gtf.org>
References: <4828D529.3060201@gtf.org> <20080513205140.GA11808@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:34455 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759475AbYEMW3p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 May 2008 18:29:45 -0400
In-Reply-To: <20080513205140.GA11808@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry, I meant to say I couldn't see the box when I was typing up the 
email, it was indeed 2.6.23-gentoo-r8.

In the interest of saving your time, I managed to fix it, and I'm not 
entirely sure why, but here's what I continued to do:

I took the network cable, and connected both onboard ports to it.  This 
caused the NIC ports to turn on the orange (instead of green) light, as 
expected normally.  Otherwise, the connection light would only be green 
prior to the kernel module load from a cold boot (once the module loads, 
the link light went dead and would stay dead).  Next I connected the port 
to a 100MB switch and now the link came back up.  Plugged the cable back 
to the gigabit switch, and link stays down.  Forced the eth0 to 100MB and 
the link came back up.  Switch back to Autoneg (where ethtool had 
constantly said it was) and bang my card link stay up when disconnecting 
and reconnecting.  Honestly, I suppose I should have tried this 
previously, but I'd not had this problem on reboot any in the past, it's 
always been autoneg and ethtool was reporting as expected for that option. 
Very strange.  Thanks for wasting your time though.  Not sure what would 
need to be done for the driver for this as I'm not really sure how it got 
to the state it was in just by that reboot.

-Ack


On Tue, 13 May 2008, Francois Romieu wrote:

> ackman <ackman@gtf.org> :
>> I've spent the better part of a day researching this to no avail.  I run
>> Gentoo on an Abit AB9 PRO P965 board.  It has two onboard ports for a
>> Realtek 8111B Gigabit interface.  I have been running 2.6.23-gentoo-r8 (I
>> think) kernel sources.
>
> uname -a should help figuring the exact version.
>
> [...]
>> being turn on.  It just mysteriously has stopped being alive.  lspci shows
>> the devices, their given eth0 and eth1 as usual, I can disable them in the
>> bios and watch Linux recognize they're missing, but still I can't for the
>> life of me get them to act properly.  I've tried turning off ACPI, I've
>> tried 2.6.24-gentoo-r7 kernel, I've tried the Realtek driver source for
>> r8168.  ACPI support was the only thing I can think of that has been a
>> major change on the system anytime recently.
>> Any suggestions would be helpful.
>
> Can you give noapic, pci=nomsi, pci=nommconf a try and send both
> 'lspci -H1 -vvxx' and 'lspci -vvxx' output ?
>
> The 'XID' line produced by dmesg would be welcome too.
>
> -- 
> Ueimor
>
