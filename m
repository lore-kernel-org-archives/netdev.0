From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH V2 net-next 0/1] ptp: add pseudo pps ioctl
Date: Wed, 31 Oct 2012 17:19:06 +0100
Message-ID: <cover.1351696507.git.richardcochran@gmail.com>
Cc: David Miller <davem@davemloft.net>,
	Jacob Keller <jacob.e.keller@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Miroslav Lichvar <mlichvar@redhat.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:56974 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423233Ab2JaQTT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2012 12:19:19 -0400
Received: by mail-ea0-f174.google.com with SMTP id c13so623044eaa.19
        for <netdev@vger.kernel.org>; Wed, 31 Oct 2012 09:19:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No changes in V2, except removing the RFC label and adding Jacob's ack.

This patch adds a kind of "poor man's PPS" for use with those PHC
drivers which do not support a true PPS. Using this ioctl, user space
can estimate the system-phc offset and tune one of the clocks as
desired.

This patch has been tested on both the Intel igb (PCIe card) and the
National Semiconductor phyter (PHY via MDIO bus), and the results seem
quite promising.

This patch avoids the "timecompare" code on purpose, since experiments
have shown that code to be quite brittle, having been tuned to only
one specific kind of hardware.

Thanks,
Richard


Richard Cochran (1):
  ptp: add an ioctl to compare PHC time with system time

 drivers/ptp/ptp_chardev.c      |   32 ++++++++++++++++++++++++++++++++
 include/uapi/linux/ptp_clock.h |   14 ++++++++++++++
 2 files changed, 46 insertions(+), 0 deletions(-)

-- 
1.7.2.5
