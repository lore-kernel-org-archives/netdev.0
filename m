From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] firewire: net: set initial MTU = 1500
	unconditionally, fix IPv6 on some CardBus cards
Date: Wed, 26 Oct 2016 17:29:15 -0400 (EDT)
Message-ID: <20161026.172915.2201926740859755129.davem@davemloft.net>
References: <20161023011824.GE32569@redhat.com> <20161023162903.4166a35d@kant>
	<20161023163056.6bc38610@kant>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux1394-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, jarod@redhat.com
To: stefanr@s5r6.in-berlin.de
Return-path: <linux1394-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20161023163056.6bc38610@kant>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux1394-devel>,
	<mailto:linux1394-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux1394-devel>
List-Post: <mailto:linux1394-devel@lists.sourceforge.net>
List-Help: <mailto:linux1394-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux1394-devel>,
	<mailto:linux1394-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: linux1394-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Date: Sun, 23 Oct 2016 16:30:56 +0200

> firewire-net, like the older eth1394 driver, reduced the initial MTU to
> less than 1500 octets if the local link layer controller's asynchronous
> packet reception limit was lower.
> 
> This is bogus, since this reception limit does not have anything to do
> with the transmission limit.  Neither did this reduction affect the TX
> path positively, nor could it prevent link fragmentation at the RX path.
> 
> Many FireWire CardBus cards have a max_rec of 9, causing an initial MTU
> of 1024 - 16 = 1008.  RFC 2734 and RFC 3146 allow a minimum max_rec = 8,
> which would result in an initial MTU of 512 - 16 = 496.  On such cards,
> IPv6 could only be employed if the MTU was manually increased to 1280 or
> more, i.e. IPv6 would not work without intervention from userland.
> 
> We now always initialize the MTU to 1500, which is the default according
> to RFC 2734 and RFC 3146.
> 
> On a VIA VT6316 based CardBus card which was affected by this, changing
> the MTU from 1008 to 1500 also increases TX bandwidth by 6 %.
> RX remains unaffected.
> 
> CC: netdev@vger.kernel.org
> CC: linux1394-devel@lists.sourceforge.net
> CC: Jarod Wilson <jarod@redhat.com>
> Signed-off-by: Stefan Richter <stefanr@s5r6.in-berlin.de>

Applied.

------------------------------------------------------------------------------
The Command Line: Reinvented for Modern Developers
Did the resurgence of CLI tooling catch you by surprise?
Reconnect with the command line and become more productive. 
Learn the new .NET and ASP.NET CLI. Get your free copy!
http://sdm.link/telerik
