From: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
Subject: 3c59x collisions statistic
Date: Fri, 14 Jan 2005 15:33:23 +0100
Message-ID: <20050114143323.GA20922@gareth.mathematik.tu-chemnitz.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Network Development Mailing List <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>, Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The collisions statistic of the 3c59x driver seems to be not correct.
While looking closer to the update_stats() function of the 3c59x driver I found
that vp->stats.collisions counts just the value of the
SingleCollisions register. The SingleCollisions register counts the number 
of packets that are transmitted without error after one and only one collision. 
Packets with multiple collisions are not counted. Therefore the value
of the SingleCollisions register is just a lower bound on the total number of 
collisions.
As far as I know, vp->stats.collisions should count the total number of 
collisions during the transmisson of each packet (not just the number of packets
which are transmitted after a single collision).
Unfortunately it seems to be impossible to calculate the total number of
collisions from the statistic counters of the NIC. But it would be possible
to count the total number of packets with collisions during the transmission in
vp->stats.collisions.
IMHO this is better then just counting packets with a single collision 
in vp->stats.collisions.

	Steffen
