From: =?UTF-8?q?Niklas=20S=C3=B6derlund?=
	<niklas.soderlund+renesas@ragnatech.se>
Subject: [PATCH 0/2] ravb: add sleep PM suspend/resume support
Date: Wed,  3 Aug 2016 15:56:45 +0200
Message-ID: <20160803135647.23242-1-niklas.soderlund+renesas@ragnatech.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, wsa@the-dreams.de,
	=?UTF-8?q?Niklas=20S=C3=B6derlund?=
	<niklas.soderlund+renesas@ragnatech.se>
To: netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org,
	sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-4.sys.kth.se ([130.237.48.193]:59982 "EHLO
	smtp-4.sys.kth.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753254AbcHCOKM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Aug 2016 10:10:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This series adds sleep PM suspend/resume support to the ravb driver. It 
is based on v4.7 and tested on Salvator-X.

I used NFS root filesystem and was able to suspend/resume and keep the 
system working. I also tested suspend/resume with a initramfs when the 
interface was down (ifconfig eth0 down) and it was no problems starting 
after suspend/resume cycle.  Note that there is a known issue on 
Salvator-X where the system will wake up immediately after it have been 
suspended so the system is not suspended for long.

I was not able to test suspend/resume on a Gen2 board due to lack of 
daugterboard, so if anyone could do that it would be great. Sergei have 
promised to try and find the time to test it in his 'copious free time' 
:-) The test procedure is quiet simple:

1. Apply patches
2. Boot and verify network is working
3. Suspend system 'echo mem > /sys/power/state'
4. Wake up system
5. Verify network is still working

Niklas Söderlund (2):
  ravb: use SET_RUNTIME_PM_OPS macro
  ravb: add sleep PM suspend/resume support

 drivers/net/ethernet/renesas/ravb_main.c | 75 +++++++++++++++++++++++++++-----
 1 file changed, 65 insertions(+), 10 deletions(-)

-- 
2.9.0
