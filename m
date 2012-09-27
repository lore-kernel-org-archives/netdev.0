From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH RFC net-next 0/1] ptp: add pseudo pps ioctl
Date: Thu, 27 Sep 2012 20:12:15 +0200
Message-ID: <cover.1348768886.git.richardcochran@gmail.com>
Cc: David Miller <davem@davemloft.net>,
	Jacob Keller <jacob.e.keller@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Miroslav Lichvar <mlichvar@redhat.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:56405 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753276Ab2I0SM2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2012 14:12:28 -0400
Received: by wibhr7 with SMTP id hr7so2384082wib.1
        for <netdev@vger.kernel.org>; Thu, 27 Sep 2012 11:12:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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

 drivers/ptp/ptp_chardev.c |   32 ++++++++++++++++++++++++++++++++
 include/linux/ptp_clock.h |   14 ++++++++++++++
 2 files changed, 46 insertions(+), 0 deletions(-)

-- 
1.7.2.5
