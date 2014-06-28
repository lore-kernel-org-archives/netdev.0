From: Stefan Wahren <info@lategoodbye.de>
Subject: Packet loss when txqueuelen is zero
Date: Sat, 28 Jun 2014 12:59:27 +0200
Message-ID: <53AEA00F.6060500@lategoodbye.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.augenpunkt.de ([213.239.207.9]:44429 "EHLO
	www.augenpunkt.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751460AbaF1LLW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Jun 2014 07:11:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

i'm new to Linux network driver development and currently i want to port 
the QCA7000 network driver to mainline [1]. I concentrate my tests on tx 
buffering since my last QCA7000 patch RFC [2]. Now i've found a test 
scenario which leads to packet loss:

host A          Powerline       host B
(QCA7000)       Ethernet        Ethernet
192.168.1.3     adaptor         192.168.1.5
|------------------|---------------|
      Homeplug         Ethernet
      10 Mbit          100 Mbit

1. Reduce the txqueuelen from 100 (default value) to 0
2. Run ping in flood mode on host A to host B

ping -c 200 -s 10000 -f 192.168.1.5

3. ping reports a high packet loss

Additional information:
- QCA7000 network driver has a tx ring size of 10 packets
- the packet loss doesn't appear when txqueuelen is 100

Here are my questions:

Is the packet loss a expected result for this scenario?
If not what could be the cause of the packet loss?

[1] - https://github.com/I2SE/qca7000/tree/linux-mainline
[2] - http://www.spinics.net/lists/netdev/msg280751.html
