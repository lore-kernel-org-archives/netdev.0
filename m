From: "Chris Friesen" <cfriesen@nortel.com>
Subject: behaviour question for igb on nehalem box
Date: Fri, 09 Oct 2009 12:43:50 -0600
Message-ID: <4ACF8466.5030309@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: e1000-list <e1000-devel@lists.sourceforge.net>,
	Linux Network Development list <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


Hi all,

I've got some general questions around the expected behaviour of the
82576 igb net device.  (On a dual quad-core Nehalem box, if it matters.)

As a caveat, the box is running Centos 5.3 with their 2.6.18 kernel.
It's using the 1.3.16-k2 igb driver though, which looks to be the one
from mainline linux.

The igb driver is being loaded with no parameters specified.  At driver
init time, it's selecting 1 tx queue and 4 rx queues per device.

My first question is whether the number of queues makes sense.  I
couldn't figure out how this would happen since the rules for selecting
the number of queues seems to be the same for rx and tx.  Also, it's not
clear to me why it's limiting itself to 4 rx queues when I have 8
physical cores (and 16 virtual ones with hyperthreading enabled).

My second question is around how the rx queues are mapped to interrupts.
 According to /proc/interrupts there appears to be a 1:1 mapping between
queues and interrupts.  However, I've set up at test with a given amount
of traffic coming in to the device (from 4 different IP addresses and 4
ports).  Under this scenario, "ethtool -S" shows the number of packets
increasing for only rx queue 0, but I see the interrupt count going up
for two interrupts.

My final question is around smp affinity for the rx and tx queue
interrupts.  Do I need to affine the interrupt for each rx queue to a
single core to guarantee proper packet ordering, or can they be handled
on arbitrary cores?  Should the tx queue be affined to a particular core
or left to be handled by all cores?

Thanks,

Chris


------------------------------------------------------------------------------
Come build with us! The BlackBerry(R) Developer Conference in SF, CA
is the only developer event you need to attend this year. Jumpstart your
developing skills, take BlackBerry mobile applications to market and stay 
ahead of the curve. Join us from November 9 - 12, 2009. Register now!
http://p.sf.net/sfu/devconference
