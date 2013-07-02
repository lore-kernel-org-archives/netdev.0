From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH] pkt_sched: rate overflow fix
Date: Tue, 2 Jul 2013 18:39:54 +0800
Message-ID: <51D2ADFA.1090208@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Howells <dhowells@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	<chenweilong@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use bonding to aggregate two 82599 nics which have 4 ports and max rate is 40gbit.
Then set rate to 35gbit, the rate is overflow.

tc qdisc add dev $bond root handle 1: \
tbf latency 50ms burst 35mb rate 35gbit mtu 64k

tc qdisc show dev $bond
qdisc tbf 1: root refcnt 2 rate 640262Kbit burst 35Mb lat 50.0ms

iperf -c host -t 30 -i 10
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0-10.0 sec   764 MBytes   641 Mbits/sec
[  3] 10.0-20.0 sec   730 MBytes   612 Mbits/sec

Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
---
 include/uapi/linux/pkt_sched.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/uapi/linux/pkt_sched.h b/include/uapi/linux/pkt_sched.h
index 32aef0a..261042c 100644
--- a/include/uapi/linux/pkt_sched.h
+++ b/include/uapi/linux/pkt_sched.h
@@ -79,7 +79,7 @@ struct tc_ratespec {
        unsigned short  overhead;
        short           cell_align;
        unsigned short  mpu;
-       __u32           rate;
+       __u64           rate;
 };

 #define TC_RTAB_SIZE   1024
-- 
1.7.12
