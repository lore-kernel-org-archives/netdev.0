From: "Chad N. Tindel" <chad@tindel.net>
Subject: Re: [bonding][BUG] UDP Tx stops after link disconnection of active slave
Date: Thu, 19 Jun 2003 11:34:59 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030619153459.GA75674@calma.pair.com>
References: <Pine.LNX.4.33.0306191512060.10139-100000@jrslxjul1.npdj.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-net <linux-net@vger.kernel.org>, linux-netdev <netdev@oss.sgi.com>,
   bond-devel <bonding-devel@lists.sourceforge.net>,
   Amir Noam <amir.noam@intel.com>, Noam Marom <noam.marom@intel.com>,
   Scott Feldman <scott.feldman@intel.com>,
   "David S. Miller" <davem@redhat.com>, Jay Vosburgh <fubar@us.ibm.com>,
   Jeff Garzik <jgarzik@pobox.com>,
   Tsippy Mendelson <tsippy.mendelson@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Shmulik Hen <shmulik.hen@intel.com>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.33.0306191512060.10139-100000@jrslxjul1.npdj.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> 	We've noticed that when using configuring bonding to active backup
> mode with two slaves and running UDP stress traffic to several clients,
> traffic will stop when disconnecting the link for the current active
> slave. When re-connecting the slave the traffic will resume even though it
> is not the active slave anymore. While traffic is stopped it looks as
> though the application generating the traffic (iperf, netperf, etc.) is
> hung and doesn't generate new packets. Once link is restored the
> application wakes up again and stars sending new packets. Further
> investigation showed that slave adapters tend to stop processing the queue
> when their link is down, and therefore any packets that were already
> passed from bonding to the disconnected slave are *stuck* in the queue,
> thus causing the resources associated with those packets not to free and
> so the application hits it's resource limits and stalls. Upon link
> connection, the packets in the queue are processed and the application is
> free to allocate new resources.
> 
> Is there any safe way for bonding to empty the queue of slaves that lost
> their link/ became inactive?

Interesting.  Perhaps bonding should go through the queue and move all the 
pending packets over into the new active slave?  It'd be nice if we could
just transfer the entire IP stack around as one big object...

Chad
