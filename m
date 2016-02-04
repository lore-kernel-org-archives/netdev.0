From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: [PATCH v3 net 0/7] mvneta fixes for SMP
Date: Thu,  4 Feb 2016 22:09:22 +0100
Message-ID: <1454620169-8156-1-git-send-email-gregory.clement@free-electrons.com>
Cc: Jason Cooper <jason@lakedaemon.net>, Andrew Lunn <andrew@lunn.ch>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>,
	linux-arm-kernel@lists.infradead.org,
	Lior Amsalem <alior@marvell.com>,
	Nadav Haklai <nadavh@marvell.com>,
	Marcin Wojtas <mw@semihalf.com>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Willy Tarreau <w@1wt.eu>
To: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Following this bug report:
http://thread.gmane.org/gmane.linux.ports.arm.kernel/468173 and the
suggestions from Russell King, I reviewed all the code involving
multi-CPU. It ended with this series of patches which should improve
the stability of the driver.

During my test I found another bug which is fixed by new patch (the
second one of this new version of the series)

The two first patches fix real bugs, the others fix potential issues
in the driver.

Thanks,

Gregory

Changelog:

v1 -> v2
Fix spinlock comment. Pointed by David Miller

v2 -> v3
 - Fix typos and mistake in the comments. Pointed by Sergei Shtylyov
 - Add a new patch fixing the CPU choice in mvneta_percpu_elect
 - Use lock in last patch to prevent remaining race condition. Pointed
   by Jisheng

Gregory CLEMENT (7):
  net: mvneta: Fix for_each_present_cpu usage
  net: mvneta: Fix the CPU choice in mvneta_percpu_elect
  net: mvneta: Use on_each_cpu when possible
  net: mvneta: Remove unused code
  net: mvneta: Modify the queue related fields from each cpu
  net: mvneta: The mvneta_percpu_elect function should be atomic
  net: mvneta: Fix race condition during stopping

 drivers/net/ethernet/marvell/mvneta.c | 184 +++++++++++++++++++---------------
 1 file changed, 101 insertions(+), 83 deletions(-)

-- 
2.5.0
