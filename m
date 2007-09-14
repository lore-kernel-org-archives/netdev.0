From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: e1000 driver and samba
Date: Fri, 14 Sep 2007 10:18:19 -0700
Message-ID: <46EAC25B.2060404@intel.com>
References: <780b6f780709131904j41148fb4p827e87530b15d6e9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: L F <lfabio.linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:37144 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752367AbXINRSa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Sep 2007 13:18:30 -0400
In-Reply-To: <780b6f780709131904j41148fb4p827e87530b15d6e9@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

L F wrote:
> Folks,
> I've been playing with multiple gigabit ethernet drivers to get samba
> 3.0.25+ to work reliably. The situation is as follows.
> I have a network, one of the machines on the network is a
> server/firewall. It contains an Intel PRO1000 dual port PCI Express
> card and runs Debian-testing.
> The machine is running shorewall 3.4.5 and at present, one port of the
> PRO1000 is configured as the WAN port, the other is bridged to a tap
> device for virtualbox and is running as the LAN port.
> Samba 3.0.25+ will either lose connection or - more worrisomely -
> corrupt data in files upon sustained traffic.
> One of the tests that consistently fails is mounting a samba share
> onto any WinXP client, then trying to unzip a file from the
> mounted/mapped drive into the drive itself (i.e. unzipping
> Z:\Stuff\qqq.zip to Z:\Stuff\qqq\* ).
> If the zip file is of any significant size, one of two things will
> happen. Either the client will complain about losing connection to the
> share - with a corrisponding error in the samba logs - or everything
> will be fine.. except the files will be corrupt.
> The unusual thing is that going through the TAP interface from a
> Virtualbox machine yields no problems even when transferring tens of
> GBs of data.
> Copying a large file (500MB+) also has the same effect.
> Now, the machine worked when it was using an onboard Realtek 8169
> chipset on a 945G board from ASUS, but it worked slowly.

this slowness might have been masking the issue

> I upgraded to
> a P965 chipset, started using the realtek driver for the 8110B on that
> board.. and started getting consistent samba errors. I therefore
> killed the onboard LAN, switched to the Intel board, tried both the
> 7.6.5 driver on the Intel website AND the driver in the 2.6.20+
> kernels - 7.2.x IIRC - and it fails, less than it did with the
> realtek, but it fails. Switching back and forth between 2.6.18,
> 2.6.20.x and 2.6.22.x yielded no improvements. I could use some help,
> because I refuse to believe that there isn't a reliable PCIexpress
> gigeth/samba combo available.

I have not yet seen other reports of this issue, and it would be interesting to 
see if the stack or driver is seeing errors. Please post `ethtool -S eth0` after 
the samba connection resets or fails.

Just as a precaution, try a different ethernet cable. Even the switch in between 
the target and you might have issues.

I know our lab folks do plenty of samba testing but I will see if they can run a 
stress test against a smb target in the way that you describe.

Cheers,

Auke
