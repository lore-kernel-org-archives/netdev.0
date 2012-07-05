From: Ming Lei <tom.leiming@gmail.com>
Subject: TCP transmit performance regression
Date: Thu, 5 Jul 2012 09:45:56 +0800
Message-ID: <CACVXFVNM-Db=_793SVfRj+nxGtNG0pRFrwc_F9TGbU0FfES63A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Network Development <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:54306 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751229Ab2GEBp4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jul 2012 21:45:56 -0400
Received: by obbuo13 with SMTP id uo13so12267219obb.19
        for <netdev@vger.kernel.org>; Wed, 04 Jul 2012 18:45:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I observed that on both 3.5-rc5 and 3.5-rc5-next, TCP transmit performance
degrades a lot, see my below simple test:

1, test box
NIC: 100M USB, normally can reach > 90Mbits/sec

2, run below command on the box:
[root@root]#iperf -c 192.168.0.103 -w 131072 -t 10
------------------------------------------------------------
Client connecting to 192.168.0.103, TCP port 5001
TCP window size:   256 KByte (WARNING: requested   128 KByte)
------------------------------------------------------------
[  3] local 192.168.0.108 port 59315 connected with 192.168.0.103 port 5001
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0-10.0 sec  40.4 MBytes  33.9 Mbits/sec

note: 192.168.0.103 is another production machine running 'iperf -s -w 131072'

3, from traffic captured in wireshark, the window size of most of tcp packets
from the test box to 192.168.0.103 is set as 229, looks very weird and should
be the cause of performance regression.

4, TCP receive performance is OK.


Thanks,
-- 
Ming Lei
