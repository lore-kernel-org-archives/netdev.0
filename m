From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH V2 net-next 0/4] Convert blackfin to phc and remove timecompare
Date: Wed, 31 Oct 2012 17:27:21 +0100
Message-ID: <cover.1351696541.git.richardcochran@gmail.com>
Cc: <device-drivers-devel@blackfin.uclinux.org>,
	<uclinux-dist-devel@blackfin.uclinux.org>,
	Bob Liu <lliubbo@gmail.com>,
	David Miller <davem@davemloft.net>,
	Jacob Keller <jacob.e.keller@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Mike Frysinger <vapier@gentoo.org>,
	Sonic Zhang <sonic.zhang@analog.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:46216 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935781Ab2JaQ1h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2012 12:27:37 -0400
Received: by mail-ee0-f46.google.com with SMTP id b15so839847eek.19
        for <netdev@vger.kernel.org>; Wed, 31 Oct 2012 09:27:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Changes in V2:
  - Correct the wrong direction of the shift when converting time
    stamps to nanoseconds
  - Add John Stultz's ack on patch 4

This patch series takes care of a legacy issue in the time keeping
core by moving blackfin over to PHC model and removing the dubious
timecompare code.

The blackfin is quite similar to the other MAC based PTP hardware
clocks, and so the implementation is straightforward.

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
