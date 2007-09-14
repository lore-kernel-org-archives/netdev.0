From: "L F" <lfabio.linux@gmail.com>
Subject: e1000 driver and samba
Date: Thu, 13 Sep 2007 22:04:37 -0400
Message-ID: <780b6f780709131904j41148fb4p827e87530b15d6e9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.179]:55518 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757727AbXINCEi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Sep 2007 22:04:38 -0400
Received: by wa-out-1112.google.com with SMTP id v27so828046wah
        for <netdev@vger.kernel.org>; Thu, 13 Sep 2007 19:04:37 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Folks,
I've been playing with multiple gigabit ethernet drivers to get samba
3.0.25+ to work reliably. The situation is as follows.
I have a network, one of the machines on the network is a
server/firewall. It contains an Intel PRO1000 dual port PCI Express
card and runs Debian-testing.
The machine is running shorewall 3.4.5 and at present, one port of the
PRO1000 is configured as the WAN port, the other is bridged to a tap
device for virtualbox and is running as the LAN port.
Samba 3.0.25+ will either lose connection or - more worrisomely -
corrupt data in files upon sustained traffic.
One of the tests that consistently fails is mounting a samba share
onto any WinXP client, then trying to unzip a file from the
mounted/mapped drive into the drive itself (i.e. unzipping
Z:\Stuff\qqq.zip to Z:\Stuff\qqq\* ).
If the zip file is of any significant size, one of two things will
happen. Either the client will complain about losing connection to the
share - with a corrisponding error in the samba logs - or everything
will be fine.. except the files will be corrupt.
The unusual thing is that going through the TAP interface from a
Virtualbox machine yields no problems even when transferring tens of
GBs of data.
Copying a large file (500MB+) also has the same effect.
Now, the machine worked when it was using an onboard Realtek 8169
chipset on a 945G board from ASUS, but it worked slowly. I upgraded to
a P965 chipset, started using the realtek driver for the 8110B on that
board.. and started getting consistent samba errors. I therefore
killed the onboard LAN, switched to the Intel board, tried both the
7.6.5 driver on the Intel website AND the driver in the 2.6.20+
kernels - 7.2.x IIRC - and it fails, less than it did with the
realtek, but it fails. Switching back and forth between 2.6.18,
2.6.20.x and 2.6.22.x yielded no improvements. I could use some help,
because I refuse to believe that there isn't a reliable PCIexpress
gigeth/samba combo available.
For further reference, the kernel versions are those mentioned above,
compiled with gcc-3.4.6 and gcc-4.1.2 (current on debian-testing),
with no improvement between the two.
Any and all indications appreciated.

Regards,
Luigi Fabio
