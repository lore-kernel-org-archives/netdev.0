From: Arkadiusz =?utf-8?q?Mi=C5=9Bkiewicz?= <a.miskiewicz@gmail.com>
Subject: tg3: BMC stops responding in 3.0
Date: Fri, 23 Sep 2011 21:45:50 +0200
Message-ID: <201109232145.50449.a.miskiewicz@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:43723 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751897Ab1IWTp5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2011 15:45:57 -0400
Received: by fxe4 with SMTP id 4so4137254fxe.19
        for <netdev@vger.kernel.org>; Fri, 23 Sep 2011 12:45:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,

I was using 2.6.38.8 and recently tried to switch to 3.0.4 on Tyan S289=
1=20
platform.

This platform uses tg3:
tg3 0000:0a:09.1: eth1: Tigon3 [partno(BCM95704) rev 2003] (PCIX:133MHz=
:64-
bit) MAC address 00:e0:81:33:5e:af
tg3 0000:0a:09.1: eth1: attached PHY is 5704 (10/100/1000Base-T Etherne=
t)=20
(WireSpeed[1], EEE[0])
tg3 0000:0a:09.1: eth1: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] TSOcap=
[1]
tg3 0000:0a:09.1: eth1: dma_rwctrl[769f4000] dma_mask[64-bit]

With 2.6.38.8 everything was working fine. With 3.0.4 there is a proble=
m. As=20
soon as tg3 module is loaded or eth0 configured (can't tell which one s=
ince=20
the machine is 400km away from me and I have no way to play with it oth=
er than=20
ipmi or ssh) BMC stops responding (so all ipmitool commands over LAN st=
op=20
working). Normal tg3 activity is not affected - I can ssh-in without a =
problem=20
etc but ipmi over lan doesn't work.

=46rom ssh console "ipmitool lan print" works, shows data but for examp=
le after=20
"ipmitool mc reset cold" it doesn't recover - ipmitool returns "Invalid=
=20
channel: 255". I have to reboot to 2.6.38.8 and then issue "ipmitool mc=
 reset=20
cold" to recover.

Any idea which tg3 change could break this? Can't bisect this due remot=
e=20
access only.

I was hoping that maybe 9e975cc291d80d5e4562d6bed15ec171e896d69b
"tg3: Fix io failures after chip reset" will fix things for me but no -=
 this=20
doesn't help.
--=20
Arkadiusz Mi=C5=9Bkiewicz        PLD/Linux Team
arekm / maven.pl            http://ftp.pld-linux.org/
