From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: [PATCH net-next v2 0/4] mvneta: Introduce RSS support
Date: Fri,  4 Dec 2015 19:44:56 +0100
Message-ID: <1449254700-32685-1-git-send-email-gregory.clement@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Lior Amsalem <alior@marvell.com>, Andrew Lunn <andrew@lunn.ch>,
 Russell King - ARM Linux <linux@arm.linux.org.uk>,
 Jason Cooper <jason@lakedaemon.net>, Arnd Bergmann <arnd@arndb.de>,
 Boris BREZILLON <boris.brezillon@free-electrons.com>,
 Simon Guinot <simon.guinot@sequanux.org>, Nadav Haklai <nadavh@marvell.com>,
 Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
 Gregory CLEMENT <gregory.clement@free-electrons.com>,
 Maxime Ripard <maxime.ripard@free-electrons.com>,
 Marcin Wojtas <mw@semihalf.com>, Willy Tarreau <w@1wt.eu>,
 linux-arm-kernel@lists.infradead.org,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: "David S. Miller" <davem@davemloft.net>, linux-kernel@vger.kernel.org,
 netdev@vger.kernel.org,
 Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Hi,

this series is the first step add RSS support on mvneta.

It will allow associating an ethernet interface to a given CPU through
RSS by using "ethtool -X ethX weight". Indeed, currently I only enable
one entry in the RSS lookup table. Even if it is not really RSS, it
allows to get back the irq affinity feature we lost by using the
percpu interrupt.

The main change compared to the first version is the add of the last
patch. It is not related to RSS but it applied on top of the series so
that why I added it there. This one was suggested by Arnd and allows
better tx latency in some scenario. For example we see a more
predictable behavior regarding throughput and latency when we have
multiple threads sending out data on different CPUs, in particular
different kinds of data.

I also fixed some typos in the third patch.

Th first patch make the default queue associate to each port and no
more a global variable.

The second patch really associates the RX queues with the CPUs instead
of masking the percpu interrupts for doing it. All the RX queues are
enabled and are statically associated with the CPUs by using a modulo
of the number of present CPUs. But at this stage only one RX queue
will receive the stream.

The third patch introduces a first level of RSS support through the
ethtool functions. As explained in the introduction there is only one
entry in the RSS lookup table which permits at the end to associate an
mvneta port to a CPU through the RX queues because the mapping is
static.

Thanks,

Gregory

Gregory CLEMENT (4):
  net: mvneta: Make the default queue related for each port
  net: mvneta: Associate RX queues with each CPU
  net: mvneta: Add naive RSS support
  net: mvneta: Spread out the TX queues management on all CPUs

 drivers/net/ethernet/marvell/mvneta.c | 320 +++++++++++++++++++++++++++++-----
 1 file changed, 276 insertions(+), 44 deletions(-)

-- 
2.5.0
