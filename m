From: Andrei Dolnikov <andrey.dolnikov@cogentembedded.com>
Subject: Failure to send fragmented IP packet in case of missing ARP entry
Date: Mon, 10 Sep 2012 12:59:46 +0400
Message-ID: <504DAC02.8040808@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:38303 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756568Ab2IJI7u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Sep 2012 04:59:50 -0400
Received: by lagy9 with SMTP id y9so936953lag.19
        for <netdev@vger.kernel.org>; Mon, 10 Sep 2012 01:59:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello all,

The following issue is observed on most Linux distributions:
Transmission of fragmented IP packets in case of missing ARP entry for 
destination IP fails.
Actually ARP request is sent, and, once ARP response is received, only 
few queued fragments are transmitted. Remaining fragments are lost.
It can be easily reproduced as follows:
     # arp -d <dst IP>
     # ping -s 65000 -c 1 <dst IP>
Ping result is: "1 packets transmitted, 0 received, 100% packet loss, 
time 0ms".

The latest kernel version I tried was 3.5.0-1 x86_64, but I also was 
able to reproduce it with 3.2.x, 3.0.x and 2.6.32.
It doesn't depend on hardware: was able to reproduce with VMWare Player, 
Intel based laptop, Intel Atom and ARM based custom boards.
As I'm not a networking standards expert I'm not sure if it's a real bug 
or acceptable behaviour, but decided to raise the issue here as I can't 
reproduce this anomaly with the Windows 7 PC.

Thanks,
Andrei.
