From: Fugang Duan <b38611@freescale.com>
Subject: [PATCH v1 0/6] *** net: fec: Enable Software TSO to improve the tx performance ***
Date: Fri, 30 May 2014 10:05:46 +0800
Message-ID: <1401415552-2263-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ezequiel.garcia@free-electrons.com>, <netdev@vger.kernel.org>,
	<shawn.guo@linaro.org>, <bhutchings@solarflare.com>,
	<b38611@freescale.com>, <stephen@networkplumber.org>
To: <b20596@freescale.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1blp0189.outbound.protection.outlook.com ([207.46.163.189]:43184
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752099AbaE3D1W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 May 2014 23:27:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add SG and software TSO support for FEC.
This feature allows to improve outbound throughput performance.
Tested on imx6dl sabresd board, running iperf tcp tests shows:
	* 82% improvement comparing with NO SG & TSO patch

$ ethtool -K eth0 sg on
$ ethtool -K eth0 tso on
 [  3] local 10.192.242.108 port 35388 connected with 10.192.242.167 port 5001
 [ ID] Interval       Transfer     Bandwidth
 [  3]  0.0- 3.0 sec   181 MBytes   506 Mbits/sec

$ ethtool -K eth0 sg off
$ ethtool -K eth0 tso off
[  3] local 10.192.242.108 port 52618 connected with 10.192.242.167 port 5001
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0- 3.0 sec  99.5 MBytes   278 Mbits/sec

FEC HW support IP header and TCP/UDP hw checksum, support multi buffer descriptor transfer
one frame, but don't support HW TSO, so FEC bandwidth is limited to this.

The patch set just enable TSO feature.  Test on imx6dl sabresd board, there have 82% improvement.
The software TSO also tested on imx6sx platform, the cpu loading reduce from 100% to 52% with the
same Bandwidth, later, i will send some patch let FEC support imx6sx platform.


Fugang Duan (6):
  net: fec: Factorize the .xmit transmit function
  net: fec: Enable IP header hardware checksum
  net: fec: Factorize feature setting
  net: fec: Increase buffer descriptor entry number
  net: fec: Add Scatter/gather support
  net: fec: Add software TSO support

 drivers/net/ethernet/freescale/fec.h      |   12 +-
 drivers/net/ethernet/freescale/fec_main.c |  510 +++++++++++++++++++++++-----
 2 files changed, 427 insertions(+), 95 deletions(-)

-- 
1.7.8
