From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: [RFC PATCH 0/2] net: mvneta: Introduce RSS support
Date: Fri,  6 Nov 2015 19:35:09 +0100
Message-ID: <1446834911-29910-1-git-send-email-gregory.clement@free-electrons.com>
Cc: Jason Cooper <jason@lakedaemon.net>, Andrew Lunn <andrew@lunn.ch>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	linux-arm-kernel@lists.infradead.org,
	Lior Amsalem <alior@marvell.com>,
	Nadav Haklai <nadavh@marvell.com>,
	Marcin Wojtas <mw@semihalf.com>,
	Simon Guinot <simon.guinot@sequanux.org>,
	Maxime Ripard <maxime.ripard@free-electrons.com>,
	Boris BREZILLON <boris.brezillon@free-electrons.com>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Willy Tarreau <w@1wt.eu>
To: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

this series is a first attempt to add RSS support on mvneta.

this series will allow associating an ethernet interface to a given
CPU through RSS by using "ethtool -X ethX weight". Indeed, currently I
only enable one entry in the RSS lookup table. Even if it is not
really RSS, it allows to get back the irq affinity feature we lost by
using the percpu interrupt.

The first patch really associates the RX queues with the CPUs instead
of masking the percpu interrupts for doing it. All the RX queues are
enabled and are statically associated with the CPUs by using a modulo
of the number of present CPUs. But at this stage only one RX queue
will receive the stream.

I also choose to associate all the TX queues on the same CPU that the
one associated to the RX queue. It allows to contain all the
interrupts on the same CPU. I think that an improvement on this side
would be the support of the XPS.

The second patch introduces a first level of RSS support through the
ethtool functions. As explained in the introduction there is only one
entry in the RSS lookup table which permits at the end to associate an
mvneta port to a CPU through the RX queues because the mapping is
static.

I really would like to have some feedback before going further and
then going in the wring direction.

Thanks,


Gregory CLEMENT (2):
  net: mvneta: Associate RX queues with each CPU
  net: mvneta: Add naive RSS support

 drivers/net/ethernet/marvell/mvneta.c | 264 +++++++++++++++++++++++++++++-----
 1 file changed, 229 insertions(+), 35 deletions(-)

-- 
2.5.0
