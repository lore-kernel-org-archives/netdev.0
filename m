From: Bart De Schuymer <bdschuym@pandora.be>
Subject: Re: [PATCH] add bridging support to nfnetlink_{log,queue}
Date: Mon, 08 Aug 2005 17:43:29 +0000
Message-ID: <1123523010.3384.19.camel@localhost.localdomain>
References: <W911141491296841123491979@kostunerix.telenet-ops.be>
	<20050808132413.GA25303@rama.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "bdschuym@pandora.be" <bdschuym@telenet.be>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Harald Welte <laforge@netfilter.org>
In-Reply-To: <20050808132413.GA25303@rama.de.gnumonks.org>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

Op ma, 08-08-2005 te 15:24 +0200, schreef Harald Welte:
> > There is one case missing: the brouter case. If br0=eth0+eth1 and a
> > packet arrives at eth0 (not br0) in the IP code (not the bridge code),
> > then the indev must be eth0, not br0.  How about something like this?
> 
> Ok, I've implemented your suggested modifications now.

There's still one small issue: if CONFIG_BRIDGE_NETFILTER isn't set in
the kernel configuration but ebtables is enabled, then the physindev
should still be filled in if ebt_ulog is used. I'm afraid this will
result in more ugly ifdef's.
I don't mind making CONFIG_BRIDGE_NETFILTER mandatory for people wanting
to log the logical {in,out}put device, if you feel it would uglify the
code too much otherwise... The {in,out}dev sent to userspace will then
be different depending on whether CONFIG_BRIDGE_NETFILTER is set or not.
People can still disable bridge-nf at runtime with the right /proc
entry. This should then be stated somewhere very clearly.

cheers,
Bart
