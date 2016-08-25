From: Ed Swierk <eswierk@skyportsystems.com>
Subject: Improving OCTEON II 10G Ethernet performance
Date: Wed, 24 Aug 2016 18:29:49 -0700
Message-ID: <CAO_EM_nrb0M49YwU+gjL+bqT4V1rFj4z7DQ8juTYXgaoKet0mg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Aaro Koskinen <aaro.koskinen@nokia.com>,
        David Daney <ddaney@caviumnetworks.com>
To: linux-mips <linux-mips@linux-mips.org>,
        driverdev-devel <devel@driverdev.osuosl.org>,
        netdev <netdev@vger.kernel.org>
Return-path: <linux-mips-bounce@linux-mips.org>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org

I'm trying to migrate from the Octeon SDK to a vanilla Linux 4.4
kernel for a Cavium OCTEON II (CN6880) board running in 64-bit
little-endian mode. So far I've gotten most of the hardware features I
need working, including XAUI/RXAUI, USB, boot bus and I2C, with a
fairly small set of patches.
https://github.com/skyportsystems/linux/compare/master...octeon2

The biggest remaining hurdle is improving 10G Ethernet performance:
iperf -P 10 on the SDK kernel gets close to 10 Gbit/sec throughput,
while on my 4.4 kernel, it tops out around 1 Gbit/sec.

Comparing the octeon-ethernet driver in the SDK
(http://git.yoctoproject.org/cgit/cgit.cgi/linux-yocto-contrib/tree/drivers/net/ethernet/octeon?h=apaliwal/octeon)
against the one in 4.4, the latter appears to utilize only a single
CPU core for the rx path. It's not clear to me if there is a similar
issue on the tx side, or other bottlenecks.

I started trying to port multi-CPU rx from the SDK octeon-ethernet
driver, but had trouble teasing out just the necessary bits without
following a maze of dependencies on unrelated functions. (Dragging
major parts of the SDK wholesale into 4.4 defeats the purpose of
switching to a vanilla kernel, and doesn't bring us closer to getting
octeon-ethernet out of staging.)

Has there been any work on the octeon-ethernet driver since this patch
set? https://www.linux-mips.org/archives/linux-mips/2015-08/msg00338.html

Any hints on what to pick out of the SDK code to improve 10G
performance would be appreciated.

--Ed
