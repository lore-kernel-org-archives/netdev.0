From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 6/8] net: dsa: Add support for platform data
Date: Tue, 10 Jan 2017 22:21:17 +0100
Message-ID: <20170110212117.GO22820@lunn.ch>
References: <20170110201235.21771-1-f.fainelli@gmail.com>
 <20170110201235.21771-7-f.fainelli@gmail.com>
 <20170110204124.GL22820@lunn.ch>
 <1530c7f6-f8ba-ab32-75aa-288549f25db9@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Ingo Tuchscherer <ingo.tuchscherer@linux.vnet.ibm.com>,
 Jason Cooper <jason@lakedaemon.net>,
 Vivien Didelot <vivien.didelot@savoirfairelinux.com>, netdev@vger.kernel.org,
 open list <linux-kernel@vger.kernel.org>, Russell King <linux@armlinux.org.uk>,
 Stuart Yoder <stuart.yoder@nxp.com>,
 Martin Schwidefsky <schwidefsky@de.ibm.com>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Gregory Clement <gregory.clement@free-electrons.com>,
 Philippe Reynes <tremyfr@gmail.com>, "David S. Miller" <davem@davemloft.net>,
 "moderated list:ARM/Marvell Dove/MV78xx0/Orion SOC support"
 <linux-arm-kernel@lists.infradead.org>,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>,
	John Crispin <john@phrozen.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <1530c7f6-f8ba-ab32-75aa-288549f25db9@gmail.com>
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

> Last time we discussed this, I had a super complex dsa2_platform_data
> that allowed you to do exactly the same thing we currently do with
> Device Tree, except that this was with platform_data. It took a lot of
> effort to get there, but I essentially had the ZII vf160 board example
> re-implemented and verified with a mockup driver (still have it in a
> branch that's not too far from net-next/master).

One thing different this time is you have associated the platform data
to an MDIO device. So the platform data represents one switch, not the
whole complex. This is going to make the platform data much simpler,
and allow the core to do the work of assembling the multiple platform
datas into one switch complex. So basically, the platform data is
dsa_chip_data.

To handle multi-CPUs, we need to move the master ethernet device and
put it next to the cpu port. So add a

struct device   *netdev[DSA_MAX_PORTS];

to dsa_chip_data. It then becomes easy to represent multiple CPU
ports.

> I would very much like to see the patches and then make a decision based
> on the submission rather than project a decision on code that has not
> been submitted yet.

The first version was posted a week ago. I requested a lot of
changes. So lets see what John says about when the next version will
be ready.

   Andrew
