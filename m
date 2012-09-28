From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH RFC net-next 0/4] Convert blackfin to phc and remove timecompare
Date: Fri, 28 Sep 2012 19:20:24 +0200
Message-ID: <cover.1348851539.git.richardcochran@gmail.com>
Cc: <device-drivers-devel@blackfin.uclinux.org>,
	<uclinux-dist-devel@blackfin.uclinux.org>,
	David Miller <davem@davemloft.net>,
	Jacob Keller <jacob.e.keller@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Mike Frysinger <vapier@gentoo.org>,
	Miroslav Lichvar <mlichvar@redhat.com>,
	Patrick Ohly <patrick.ohly@intel.com>,
	Sonic Zhang <sonic.zhang@analog.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:44262 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757648Ab2I1RUm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2012 13:20:42 -0400
Received: by wibhr7 with SMTP id hr7so87594wib.1
        for <netdev@vger.kernel.org>; Fri, 28 Sep 2012 10:20:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series takes care of a legacy issue in the time keeping
core by moving blackfin over to PHC model and removing the dubious
timecompare code.

The blackfin is quite similar to the other MAC based PTP hardware
clocks, and so the implementation is straightforward. However, I don't
have a board to test this on, and I would really appreciate if someone
would test this for me. If anyone wants to lend me a board or make one
available for remote login, please let me know.

The first patch is a bug fix that should be merged in any
case. Pacthes two and three convert the bfin_mac to offer a PHC
device. The last patch removes the timecompare code.

Thanks,
Richard


Richard Cochran (4):
  bfin_mac: only advertise hardware time stamped when enabled.
  bfin_mac: replace sys time stamps with raw ones instead.
  bfin_mac: offer a PTP Hardware Clock.
  time: remove the timecompare code.

 drivers/net/ethernet/adi/Kconfig    |    2 +-
 drivers/net/ethernet/adi/bfin_mac.c |  259 ++++++++++++++++++++++++++---------
 drivers/net/ethernet/adi/bfin_mac.h |   13 +-
 include/linux/timecompare.h         |  125 -----------------
 kernel/time/Makefile                |    2 +-
 kernel/time/timecompare.c           |  193 --------------------------
 6 files changed, 205 insertions(+), 389 deletions(-)
 delete mode 100644 include/linux/timecompare.h
 delete mode 100644 kernel/time/timecompare.c

-- 
1.7.2.5
