From: Holger Kiehl <Holger.Kiehl@dwd.de>
Subject: qlcnic very high TX values, as of 3.13.x
Date: Fri, 11 Jul 2014 09:12:44 +0000 (UTC)
Message-ID: <alpine.LRH.2.11.1407110911560.20203@diagnostix.dwd.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
To: linux-netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ofcsgdbm.dwd.de ([141.38.3.245]:33372 "EHLO ofcsgdbm.dwd.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751042AbaGKJU2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jul 2014 05:20:28 -0400
Received: from localhost (localhost [127.0.0.1])
	by ofcsgdn4.dwd.de (Postfix) with ESMTP id 3A60D49F77
	for <netdev@vger.kernel.org>; Fri, 11 Jul 2014 09:12:45 +0000 (UTC)
Received: from ofcsgdn4.dwd.de ([127.0.0.1])
	by localhost (ofcsgdn4.csg.lan [127.0.0.1]) (amavisd-new, port 10024)
	with LMTP id eyiGwjH9TYk9 for <netdev@vger.kernel.org>;
	Fri, 11 Jul 2014 09:12:45 +0000 (UTC)
Received: from mailhub.dwd.de (oflsv148.dwd.de [141.38.42.197])
	by ofcsgdn4.dwd.de (Postfix) with ESMTP id 149BA49F75
	for <netdev@vger.kernel.org>; Fri, 11 Jul 2014 09:12:45 +0000 (UTC)
Received: from diagnostix.dwd.de (diagnostix.dwd.de [141.38.42.141])
	by mailhub.dwd.de (Postfix) with ESMTP id 02EFE9C07
	for <netdev@vger.kernel.org>; Fri, 11 Jul 2014 09:12:45 +0000 (UCT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

upgrading from 3.10.x to the next stable series 3.14.x I noticed that
ifconfig reports very high TX values. Taking the qlcnic source from
3.15.5 and compile it under 3.14.12, the problem remains. Going
backwards always just copying the qlcnic source from the older kernels
to the 3.14.12 tree, I noticed that the 3.12.x kernel was the last
version that does not generate those high TX values. So the problem
started with the qlcnic driver in 3.13.x. However, comparing 3.13.x
and 3.14.x the numbers go higher in 3.14.x much quicker. In 3.14.x
I get TX values in Terabytes very quickly after boot. I once even got
Petabyte values!

Hardware is the following:

      HP ProLiant DL380 G7
      2 x Intel Xeon X5690 (24 cores with hypertreading)
      106 GByte Ram
      1 x NC523SFP 10Gb 2-port Server Adapter Board Chip rev 0x54 (qlcnic)
      1 x Intel Corporation 82599ES 10-Gigabit SFI/SFP+ Network Connection
      (ixgbe)

The qlcnic and ixgbe cards are bonded together in fault-tolerance
(active-backup) mode. And even when I switch to the Intel card, after I
get crazy TX values on qlcnic card, the TX vaules on this card still
go up at a very quick rate. This only stops when I reset the card
(reload the module). Also, there is no differnce if I compile the driver
in or use it as module. There are no strange messages in
/var/log/messages or dmesg. Here the output with the 3.13.x driver in
3.14.12 when system boots:

     [   18.229195] QLogic 1/10 GbE Converged/Intelligent Ethernet Driver
     v5.3.52
     [   18.229415] qlcnic 0000:1a:00.0: 2048KB memory map
     [   18.854134] qlcnic 0000:1a:00.0: Default minidump capture mask 0x1f
     [   19.602491] qlcnic 0000:1a:00.0: FW dump enabled
     [   19.631257] qlcnic 0000:1a:00.0: Supports FW dump capability
     [   19.667072] qlcnic 0000:1a:00.0: Driver v5.3.52, firmware v4.14.26
     [   19.704279] qlcnic 0000:1a:00.0: Set 4 Tx rings
     [   19.733001] qlcnic 0000:1a:00.0: Set 4 SDS rings
     [   19.898808] qlcnic: 2c:27:d7:50:04:48: NC523SFP 10Gb 2-port Server
     Adapter Board Chip rev 0x54
     [   19.949325] qlcnic 0000:1a:00.0: irq 129 for MSI/MSI-X
     [   19.949329] qlcnic 0000:1a:00.0: irq 130 for MSI/MSI-X
     [   19.949333] qlcnic 0000:1a:00.0: irq 131 for MSI/MSI-X
     [   19.949336] qlcnic 0000:1a:00.0: irq 132 for MSI/MSI-X
     [   19.949340] qlcnic 0000:1a:00.0: irq 133 for MSI/MSI-X
     [   19.949343] qlcnic 0000:1a:00.0: irq 134 for MSI/MSI-X
     [   19.949347] qlcnic 0000:1a:00.0: irq 135 for MSI/MSI-X
     [   19.949350] qlcnic 0000:1a:00.0: irq 136 for MSI/MSI-X
     [   19.949369] qlcnic 0000:1a:00.0: using msi-x interrupts
     [   19.982782] qlcnic 0000:1a:00.0: Set 4 Tx queues
     [   20.055099] qlcnic 0000:1a:00.0: eth2: XGbE port initialized
     [   20.090408] qlcnic 0000:1a:00.1: 2048KB memory map
     [   20.179836] qlcnic 0000:1a:00.1: Default minidump capture mask 0x1f
     [   20.217848] qlcnic 0000:1a:00.1: FW dump enabled
     [   20.246979] qlcnic 0000:1a:00.1: Supports FW dump capability
     [   20.282318] qlcnic 0000:1a:00.1: Driver v5.3.52, firmware v4.14.26
     [   20.320238] qlcnic 0000:1a:00.1: Set 4 Tx rings
     [   20.350038] qlcnic 0000:1a:00.1: Set 4 SDS rings
     [   20.429714] qlcnic 0000:1a:00.1: irq 137 for MSI/MSI-X
     [   20.429718] qlcnic 0000:1a:00.1: irq 138 for MSI/MSI-X
     [   20.429722] qlcnic 0000:1a:00.1: irq 139 for MSI/MSI-X
     [   20.429726] qlcnic 0000:1a:00.1: irq 140 for MSI/MSI-X
     [   20.429729] qlcnic 0000:1a:00.1: irq 141 for MSI/MSI-X
     [   20.429732] qlcnic 0000:1a:00.1: irq 142 for MSI/MSI-X
     [   20.429736] qlcnic 0000:1a:00.1: irq 143 for MSI/MSI-X
     [   20.429739] qlcnic 0000:1a:00.1: irq 144 for MSI/MSI-X
     [   20.429757] qlcnic 0000:1a:00.1: using msi-x interrupts
     [   20.458895] qlcnic 0000:1a:00.1: Set 4 Tx queues
     [   20.486907] qlcnic 0000:1a:00.1: eth3: XGbE port initialized

My kernel config can be downloaded here:

    ftp://ftp.dwd.de/pub/afd/test/.config

Please, just ask if I need to provide more details and please CC me,
since I am not on the list.

Thanks,
Holger
