From: Shmulik Hen <shmulik.hen@intel.com>
Subject: [bonding][BUG] UDP Tx stops after link disconnection of active slave
Date: Thu, 19 Jun 2003 16:32:29 +0300 (IDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.33.0306191512060.10139-100000@jrslxjul1.npdj.intel.com>
Reply-To: Shmulik Hen <shmulik.hen@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Amir Noam <amir.noam@intel.com>, Noam Marom <noam.marom@intel.com>,
   Scott Feldman <scott.feldman@intel.com>,
   Shmulik Hen <shmulik.hen@intel.com>,
   "Chad N. Tindel" <ctindel@calma.pair.com>,
   "David S. Miller" <davem@redhat.com>, Jay Vosburgh <fubar@us.ibm.com>,
   Jeff Garzik <jgarzik@pobox.com>,
   Tsippy Mendelson <tsippy.mendelson@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-net <linux-net@vger.kernel.org>, linux-netdev <netdev@oss.sgi.com>,
   bond-devel <bonding-devel@lists.sourceforge.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

	We've noticed that when using configuring bonding to active backup
mode with two slaves and running UDP stress traffic to several clients,
traffic will stop when disconnecting the link for the current active
slave. When re-connecting the slave the traffic will resume even though it
is not the active slave anymore. While traffic is stopped it looks as
though the application generating the traffic (iperf, netperf, etc.) is
hung and doesn't generate new packets. Once link is restored the
application wakes up again and stars sending new packets. Further
investigation showed that slave adapters tend to stop processing the queue
when their link is down, and therefore any packets that were already
passed from bonding to the disconnected slave are *stuck* in the queue,
thus causing the resources associated with those packets not to free and
so the application hits it's resource limits and stalls. Upon link
connection, the packets in the queue are processed and the application is
free to allocate new resources.

Is there any safe way for bonding to empty the queue of slaves that lost
their link/ became inactive?

-- 
| Shmulik Hen                             |
| Israel Design Center (Jerusalem)        |
| LAN Access Division                     |
| Intel Communications Group, Intel corp. |
