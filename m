From: John Crosbie <john@excelfore.com>
Subject: LAN9514 eeprom problems
Date: Thu, 15 Sep 2011 22:20:31 -0700
Message-ID: <CACDsFyuW6dTJv1zxC8CrmgUJ+t9pdAUZZS=++1meqcuOxXj3DA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: steve.glendinning@smsc.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:41971 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752100Ab1IPFUc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2011 01:20:32 -0400
Received: by gxk6 with SMTP id 6so2004768gxk.5
        for <netdev@vger.kernel.org>; Thu, 15 Sep 2011 22:20:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Steve,

I am working on an ARM7 board that contains a LAN9514 with 93LC66A
eeprom. The Linux kernel version is 2.6.32.=A0 I am seeing problems
programming the eeprom with ethtool.

If I read then it works as expected:

ethtool -e usb0
will give 512 ff's

Then I issue the command:

ethtool -E usb0 magic 0x9500 offset 0 length 1 value 0xdd

and get:
[=A0=A0 72.779431] usb0: eeprom: EWEN a0000000
[=A0=A0 72.784211] usb0: eeprom ready
[=A0=A0 72.818265] usb0: EEPROM read operation timeout val=3D30000400
Cannot set EEPROM data: Input/output error

The 1st two kernel messages have been added by me along with printing t=
he value.
I can see with a o'scope that the signalling at the chip looks good
but it appears that the 9514 returns timeout before the 93LC66 has
finished its writing busy cycle.
After doing this, if I read again then I get a timeout again:

root@2065:~# ethtool -e usb0
[   95.889447] usb0: EEPROM read operation timeout val=3D00000400
Cannot get EEPROM data: Input/output error

I have to reboot to get read to work again.

My problem is that I cannot find any register level specs for the
9514.  I have the data sheet and the software manual.  The datasheet
describes the hardware pins and the software manual describes the
device drivers but there is a big document missing inbetween these
two.
I have seen that the driver provided on the SMSC website performs many
retries that the kernel.org driver does not when reading and writing
registers.  Are these really required.  Any suggestions/pointer would
be appreciated.

Regards,

John Crosbie
Excelfore
