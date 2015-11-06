From: Simon Xiao <sixiao@microsoft.com>
Subject: linux-next network throughput performance regression
Date: Fri, 6 Nov 2015 20:31:13 +0000
Message-ID: <CY1PR03MB13760C9F1AABC4EBC455B85CC4280@CY1PR03MB1376.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Haiyang Zhang <haiyangz@microsoft.com>, David Miller <davem@davemloft.net>
To: "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Language: en-US
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

I compared the network throughput performance on SLES12 bare metal servers, between SLES12 default kernel and latest linux-next (2015-11-05) kernel, based on the test results, I suspect there is a network regression exists on Linux-Next over the 40G Ethernet network:
a) iperf3 reports 50% performance drop with single TCP stream on latest linux-next;
b) iperf3 reports 10% ~ 30% performance drop with 2 to 128 TCP streams on latest linux-next;
Another throughput benchmarking tool (ntttcp-for-linux) test result is also listed at the end of the email for reference.


Server configuration:
------------------------------
Two servers (one client and one server, cross linked by 40G Ethernet), which have:
a) CPU: Intel(R) Xeon(R) CPU E5-2667 v3 @ 3.20GHz, 2 sockets, 16 CPUs, cache size : 20480 KB
b) Memory: 64 GB
c) Ethernet controller: Mellanox Technologies MT27520 Family [ConnectX-3 Pro], 40G Ethernet, default driver


Test with iperf3:
------------------------------
iperf3: https://github.com/esnet/iperf

a) SLES12 default kernel, network throughput tested by iperf3:
Test Connections	1	2	4	8	16	32	64	128	
Throughput (G bps)	36.7	37.3	37.6	37.7	37.7	37.7	37.7	25.7		

b) SLES12 + Linux-Next 20151105, network throughput tested by iperf3:
Test Connections	1	2	4	8	16	32	64	128
Throughput (G bps)	18.2	32.2	34.6	32.8	27.6	32.0	27.0	21.3
Percentage dropped	-50%	-14%	-8%	-13%	-27%	-15%	-28%	-17%


Test with ntttcp-for-linux:
------------------------------
ntttcp-for-linux: https://github.com/Microsoft/ntttcp-for-linux 

a) SLES12 default kernel, network throughput tested by ntttcp-for-linux:
Test Connections	1	2	4	8	16	32	64	128	256	512
Throughput (Gbps)	36.19	37.29	37.67	37.68	37.7	37.72	37.74	37.76	37.81	37.9	

b) SLES12 + Linux-Next 20151105, network throughput tested by ntttcp-for-linux:
Test Connections	1	2	4	8	16	32	64	128	256	512	
Throughput (Gbps)	28.12	34.01	37.6	36.53	32.94	33.07	33.63	33.44	33.83	34.42	
Percentage dropped	-22%	-9%	0%	-3%	-13%	-12%	-11%	-11%	-11%	-9%
