From: Yuanhan Liu <yuanhan.liu@linux.intel.com>
Subject: [net-next:master 122/152] drivers/ptp/ptp_chardev.c:36 ptp_ioctl()
 warn: 'sysoff' puts 832 bytes on stack
Date: Fri, 2 Nov 2012 10:06:31 +0800
Message-ID: <20121102020631.GI16883@yliu-dev.sh.intel.com>
References: <509326ff.Rs30l/1GTlOl9dW+%yuanhan.liu@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Yuanhan Liu <yuanhan.liu@linux.intel.com>,
	changlongx.xie@intel.com, fengguang.wu@intel.com,
	netdev@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:11980 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762620Ab2KBCG0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Nov 2012 22:06:26 -0400
Content-Disposition: inline
In-Reply-To: <509326ff.Rs30l/1GTlOl9dW+%yuanhan.liu@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi Richard,

_just_ FYI and let you aware of it, there are new smatch warnings show up in

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
head:   b77bc2069d1e437d5a1a71bb5cfcf4556ee40015
commit: 215b13dd288c2e1e4461c1530a801f5f83e8cd90 [122/152] ptp: add an ioctl to compare PHC time with system time

+ drivers/ptp/ptp_chardev.c:36 ptp_ioctl() warn: 'sysoff' puts 832 bytes on stack
  drivers/ptp/ptp_chardev.c:144 ptp_read() warn: 'event' puts 960 bytes on stack

vim +36 +/sysoff drivers/ptp/ptp_chardev.c

d94ba80e Richard Cochran 2011-04-22  20  #include <linux/module.h>
d94ba80e Richard Cochran 2011-04-22  21  #include <linux/posix-clock.h>
d94ba80e Richard Cochran 2011-04-22  22  #include <linux/poll.h>
d94ba80e Richard Cochran 2011-04-22  23  #include <linux/sched.h>
d94ba80e Richard Cochran 2011-04-22  24  
d94ba80e Richard Cochran 2011-04-22  25  #include "ptp_private.h"
d94ba80e Richard Cochran 2011-04-22  26  
d94ba80e Richard Cochran 2011-04-22  27  int ptp_open(struct posix_clock *pc, fmode_t fmode)
d94ba80e Richard Cochran 2011-04-22  28  {
d94ba80e Richard Cochran 2011-04-22  29  	return 0;
d94ba80e Richard Cochran 2011-04-22  30  }
d94ba80e Richard Cochran 2011-04-22  31  
d94ba80e Richard Cochran 2011-04-22  32  long ptp_ioctl(struct posix_clock *pc, unsigned int cmd, unsigned long arg)
d94ba80e Richard Cochran 2011-04-22  33  {
d94ba80e Richard Cochran 2011-04-22  34  	struct ptp_clock_caps caps;
d94ba80e Richard Cochran 2011-04-22  35  	struct ptp_clock_request req;
215b13dd Richard Cochran 2012-10-31 @36  	struct ptp_sys_offset sysoff;
d94ba80e Richard Cochran 2011-04-22  37  	struct ptp_clock *ptp = container_of(pc, struct ptp_clock, clock);
d94ba80e Richard Cochran 2011-04-22  38  	struct ptp_clock_info *ops = ptp->info;
215b13dd Richard Cochran 2012-10-31  39  	struct ptp_clock_time *pct;
215b13dd Richard Cochran 2012-10-31  40  	struct timespec ts;
d94ba80e Richard Cochran 2011-04-22  41  	int enable, err = 0;
215b13dd Richard Cochran 2012-10-31  42  	unsigned int i;
d94ba80e Richard Cochran 2011-04-22  43  
d94ba80e Richard Cochran 2011-04-22  44  	switch (cmd) {

---
0-DAY kernel build testing backend         Open Source Technology Center
Fengguang Wu, Yuanhan Liu                              Intel Corporation
