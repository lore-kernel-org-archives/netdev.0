From: jamal <hadi@cyberus.ca>
Subject: [ofa-general] [PATCHES] TX batching rev2
Date: Mon, 08 Oct 2007 14:21:21 -0400
Message-ID: <1191867681.4335.28.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, peter.p.waskiewicz.jr@intel.com, kumarkr@linux.ibm.com,
	herbert@gondor.apana.org.au, gaagaan@gmail.com,
	Robert.Olsson@data.slu.se, netdev@vger.kernel.org,
	rdreier@cisco.com, mcarlson@broadcom.com,
	randy.dunlap@oracle.com, jagana@us.ibm.com,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	jeff@garzik.org, sri@us.ibm.com, shemminger@linux-foundation.org,
	kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <general-bounces@lists.openfabrics.org>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org


Please provide feedback on the code and/or architecture.
Last time i posted them i received little. They are now updated to 
work with the latest net-2.6.24 from a few hours ago.

Patch 1: Introduces batching interface
Patch 2: Core uses batching interface
Patch 3: get rid of dev->gso_skb

What has changed since i posted last:
Killed the temporary packet list that is passed to qdisc restart.

Dave please let me know if this meets your desires to allow devices
which are SG and able to compute CSUM benefit just in case i
misunderstood. 
Herbert, if you can look at at least patch 3 i will appreaciate it
(since it kills dev->gso_skb that you introduced).

UPCOMING PATCHES
---------------
As before:
More patches to follow later if i get some feedback - i didnt want to 
overload people by dumping too many patches. Most of these patches 
mentioned below are ready to go; some need some re-testing and others 
need a little porting from an earlier kernel: 
- tg3 driver 
- tun driver
- pktgen
- netiron driver
- e1000 driver (LLTX)
- e1000e driver (non-LLTX)
- ethtool interface
- There is at least one other driver promised to me

Theres also a driver-howto i wrote that was posted on netdev last week
as well as one that describes the architectural decisions made.

PERFORMANCE TESTING
--------------------

System under test hardware is still a 2xdual core opteron with a 
couple of tg3s. 
A test tool generates udp traffic of different sizes for upto 60 
seconds per run or a total of 30M packets. I have 4 threads each 
running on a specific CPU which keep all the CPUs as busy as they can 
sending packets targetted at a directly connected box's udp discard
port.
All 4 CPUs target a single tg3 to send. The receiving box has a tc rule 
which counts and drops all incoming udp packets to discard port - this
allows me to make sure that the receiver is not the bottleneck in the
testing. Packet sizes sent are {8B, 32B, 64B, 128B, 256B, 512B, 1024B}. 
Each packet size run is repeated 10 times to ensure that there are no
transients. The average of all 10 runs is then computed and collected.

I do plan also to run forwarding and TCP tests in the future when the
dust settles.

cheers,
jamal
