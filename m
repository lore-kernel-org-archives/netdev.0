From: Dave Jones <davej@codemonkey.org.uk>
Subject: ssh connections hanging on 4.1rc7
Date: Thu, 11 Jun 2015 13:46:18 -0400
Message-ID: <20150611174618.GA30268@codemonkey.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from arcturus.aphlor.org ([188.246.204.175]:60336 "EHLO
	arcturus.aphlor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755073AbbFKRq0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2015 13:46:26 -0400
Received: from [209.6.119.210] (helo=wopr.kernelslacker.org)
	by arcturus.aphlor.org with esmtpsa (TLSv1.2:DHE-RSA-AES256-GCM-SHA384:256)
	(Exim 4.84)
	(envelope-from <davej@codemonkey.org.uk>)
	id 1Z36YW-0005WP-OH
	for netdev@vger.kernel.org; Thu, 11 Jun 2015 18:46:21 +0100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just hit this weird problem where I can ssh into a machine once,
then after logging out, subsequent ssh connections hang.

The client side looks like..

13:39:06.307781 IP wopr.kernelslacker.org.43982 > gelk.kernelslacker.org.ssh: Flags [S], seq 319726787, win 29200, options [mss 1460,sackOK,TS val 77408596 ecr 0,nop,wscale 7], length 0
13:39:06.308580 IP wopr.kernelslacker.org.43982 > gelk.kernelslacker.org.ssh: Flags [P.], seq 319726788:319726820, ack 1404309216, win 229, options [nop,nop,TS val 77408597 ecr 19368680], length 32
13:39:06.332551 IP wopr.kernelslacker.org.43982 > gelk.kernelslacker.org.ssh: Flags [P.], seq 32:2000, ack 33, win 229, options [nop,nop,TS val 77408621 ecr 19368703], length 1968
13:39:06.370042 IP wopr.kernelslacker.org.43982 > gelk.kernelslacker.org.ssh: Flags [P.], seq 2048:2064, ack 1265, win 258, options [nop,nop,TS val 77408658 ecr 19368734], length 16
13:39:06.449511 IP wopr.kernelslacker.org.43982 > gelk.kernelslacker.org.ssh: Flags [.], ack 1309, win 258, options [nop,nop,TS val 77408738 ecr 19368782], length 0

until I ctrl-c which then sends the FIN

13:40:06.914614 IP wopr.kernelslacker.org.43982 > gelk.kernelslacker.org.ssh: Flags [F.], seq 2108, ack 1309, win 258, options [nop,nop,TS val 77469203 ecr 19368782], length 0


On the sshd side..


13:39:06.311005 IP wopr.kernelslacker.org.43982 > gelk.kernelslacker.org.ssh: Flags [S], seq 319726787, win 29200, options [mss 1460,sackOK,TS val 77408596 ecr 0,nop,wscale 7], length 0
13:39:06.311254 IP wopr.kernelslacker.org.43982 > gelk.kernelslacker.org.ssh: Flags [.], ack 1404309216, win 229, options [nop,nop,TS val 77408596 ecr 19368680], length 0
13:39:06.311778 IP wopr.kernelslacker.org.43982 > gelk.kernelslacker.org.ssh: Flags [P.], seq 0:32, ack 1, win 229, options [nop,nop,TS val 77408597 ecr 19368680], length 32
13:39:06.334546 IP wopr.kernelslacker.org.43982 > gelk.kernelslacker.org.ssh: Flags [.], ack 33, win 229, options [nop,nop,TS val 77408619 ecr 19368703], length 0
13:39:06.335779 IP wopr.kernelslacker.org.43982 > gelk.kernelslacker.org.ssh: Flags [P.], seq 32:2000, ack 33, win 229, options [nop,nop,TS val 77408621 ecr 19368703], length 1968
13:39:06.347867 IP wopr.kernelslacker.org.43982 > gelk.kernelslacker.org.ssh: Flags [P.], seq 2000:2048, ack 985, win 243, options [nop,nop,TS val 77408633 ecr 19368711], length 48
13:39:06.373232 IP wopr.kernelslacker.org.43982 > gelk.kernelslacker.org.ssh: Flags [P.], seq 2048:2064, ack 1265, win 258, options [nop,nop,TS val 77408658 ecr 19368734], length 16
13:39:06.413173 IP wopr.kernelslacker.org.43982 > gelk.kernelslacker.org.ssh: Flags [P.], seq 2064:2108, ack 1265, win 258, options [nop,nop,TS val 77408698 ecr 19368782], length 44
13:39:06.452714 IP wopr.kernelslacker.org.43982 > gelk.kernelslacker.org.ssh: Flags [.], ack 1309, win 258, options [nop,nop,TS val 77408738 ecr 19368782], length 0

until the ctrl-c...

13:40:06.917807 IP wopr.kernelslacker.org.43982 > gelk.kernelslacker.org.ssh: Flags [F.], seq 2108, ack 1309, win 258, options [nop,nop,TS val 77469203 ecr 19368782], length 0
13:40:06.921241 IP wopr.kernelslacker.org.43982 > gelk.kernelslacker.org.ssh: Flags [.], ack 1310, win 258, options [nop,nop,TS val 77469206 ecr 19429290], length 0


Is there anything out of the ordinary here that I'm missing, or is this perhaps
an sshd bug ?

The odd thing is that it seems repeatable with every host I try to ssh to.

4.1rc7 on both sides, haven't tried reproducing with different kernels yet.

	Dave
