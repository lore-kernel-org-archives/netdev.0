From: Roland Dreier <rdreier@cisco.com>
Subject: Re: 2.6.29 regression? Bonding tied to IPV6 in 29-rc5
Date: Tue, 17 Feb 2009 21:55:58 -0800
Message-ID: <adar61w2sr5.fsf@cisco.com>
References: <200902172001.41804.arvidjaar@mail.ru>
	<20090217.142946.232071526.davem@davemloft.net>
	<25143.1234932076@turing-police.cc.vt.edu>
	<20090217.212919.259912220.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Valdis.Kletnieks@vt.edu, arvidjaar@mail.ru, rjw@sisk.pl,
	netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net,
	jamagallon@ono.com, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755013AbZBRF4X@vger.kernel.org>
In-Reply-To: <20090217.212919.259912220.davem@davemloft.net> (David Miller's
	message of "Tue, 17 Feb 2009 21:29:19 -0800 (PST)")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > Next, if it's just an issue of IPV6 traffic, install a packet
 > scheduler rule that rejects all packets with ethernet proto
 > ETH_P_IPV6
 > 
 > If openning up ipv6 sockets is problematic, that can be blocked
 > using the security layer, which your super-duper distro kernel
 > is guarenteed to have enabled. :-)

This reminds me of a related issue that some users have run into with
IP-over-InfiniBand -- the IPoIB module also depends on ipv6 symbols if
ipv6 is enabled, so when ipoib is loaded then ipv6 gets loaded.  And
this causes a problem from some people in the IB case because assigning
an ipv6 address to the ipoib interface actually consumes some network
resources (the number of multicast groups that the network supports may
be limited and having a solicited node multicast group for each node may
use them all up).

Anyway, this leads to the folowing question: is there a way to prevent a
link-local ipv6 address from being configured automatically for the
ipoib interface?

Thanks,
  Roland
