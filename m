From: Tino Keitel <tino.keitel@tikei.de>
Subject: 2.6.19: very low transmit speed after suspend/resume with Sky2
Date: Sat, 2 Dec 2006 10:16:28 +0100
Message-ID: <20061202091626.GA20734@thinkpad.home.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from eazy.amigager.de ([213.239.192.238]:12719 "EHLO
	eazy.amigager.de") by vger.kernel.org with ESMTP id S1162855AbWLBJQ0
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 Dec 2006 04:16:26 -0500
Received: from thinkpad.home.local (port-212-202-201-86.dynamic.qsc.de [212.202.201.86])
	by eazy.amigager.de (Postfix) with ESMTP id 404A425C3AE
	for <netdev@vger.kernel.org>; Sat,  2 Dec 2006 10:16:25 +0100 (CET)
Received: from scorpion by thinkpad.home.local with local (Exim 4.63)
	(envelope-from <tino.keitel@tikei.de>)
	id 1GqQyy-0005Ya-HD
	for netdev@vger.kernel.org; Sat, 02 Dec 2006 10:16:28 +0100
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi folks,                                            
                                                     
since 2.6.19 I have the problem that I get lousy transmit speeds of < 1 
mbit/s.

Here is a quick test, the 5th column is the transfer speed in mbit/s:

>From the affected machine to my laptop over WLAN (the affected machine
is connected to a Fast Ethernet switch):

$ nttcp -r -l 1400 -n 500 dose
l   700000    8.16   0.04    0.6867    155.5469   824  101.04   22887.6     
1   700000    8.15   0.00    0.6873 560000.0000   500  61.37    50000000.0    

Only 0,68 mbit/s during transmit. :-(

>From my laptop to the affected machine:

$ nttcp -l 1400 -n 5000 dose
l  7000000    2.21   0.03   25.3427   1999.8572  5000  2262.74  178558.7     
1  7000000    2.25   0.07   24.8363    823.4810  9268  4110.41  136286.1 

This is ok, 25 mbit/s during receive, limited by the WLAN in the
laptop.

After reboot:

$ nttcp -l 1400 -n 5000 dose
l  7000000    2.04   0.03   27.5005   1749.8906  5000  2455.40  156240.2
1  7000000    2.08   0.06   26.9843    999.9464  9455  4556.00  168830.2

Now I got 27 mbit/s during receive, that's ok for WLAN.

Re-tested with 2.6.18.2 after a suspend/resume cycle:

$ nttcp -l 1500 -n 5000 dose
l  7500000  2.15  0.05   27.9219   1249.9219    5000   2326.83  104160.2
1  7500000  2.20  0.04   27.2441   1499.9250    5178   2351.16  129443.5

$ nttcp -r -l 1500 -n 5000 dose
l  7500000  2.07  0.09   28.9676    681.7794    5182   2501.83  58883.0
1  7500000  1.98  0.03   30.2748   2142.7806    5000   2522.90  178565.1

lspci output:

01:00.0 Ethernet controller: Marvell Technology Group Ltd. 88E8053
PCI-E Gigabit Ethernet Controller (rev 22)

Any hints what I could try to get the full performance in 2.6.19?

Regards,
Tino
