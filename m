From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] seastar - SeaStar Ethernet driver
Date: Thu, 4 Feb 2010 23:16:21 +0000
Message-ID: <20100204231621.7a13695a@lxorguk.ukuu.org.uk>
References: <20100202205845.GE5246@hawkeye.sandia.gov>
	<20100202.134251.15604523.davem@davemloft.net>
	<1265160242.15726.20.camel@hawkeye.sandia.gov>
	<20100202.174045.135005544.davem@davemloft.net>
	<1265324464.23523.51.camel@hawkeye.sandia.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Kevin Pedretti" <ktpedre@sandia.gov>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1265324464.23523.51.camel@hawkeye.sandia.gov>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Ethernet Frame:     [6 bytes h_dest][6 bytes h_source][2 bytes h_proto][data...]
> SeaStar DG Message: [2 bytes length][1 byte MBZ][1 byte msg type (2 << 5) for IP)][data...]
> 
> I think it would be possible to re-factor it so that the Ethernet frame
> is encapsulated in its entirety within a seastar message, rather than
> the current scheme of jamming the critical info from the Ethernet header
> into the seastar datagram header.  I will pursue that if you want... the
> drawback is that it would break compatibility with Cray's existing
> proprietary IP over SeaStar driver, making this driver pretty much
> useless for the kinds of things us and others would like to do (e.g.,
> leave service nodes booted with Cray's proprietary software stack and
> talking to compute nodes running this driver).

Perhaps it shouldn't be pretending to be an ethernet driver - that is
sort of the root cause of all the confusion and the fact things like the
bridging layer will try and grab it etc ? If it claimed to be a new
hardware type you'd take a brief hit on getting the new hw type into the
tools but it would mean

- tcpdump etc once coaxed would display seastar frames not fake ethernet
- the config tools would actually report what it really was
- non IP layers and userspace won't keep trying to do things you don't
  want (what does it do right now with vlans I wonder 8))
- there will be no ARP confusion

If it wants to stay compatible and pretend to be ethernet you probably
need a message type for "encapsulated ethernet", you can then encapsulate
anything not IP and stay compatible by keeping IP sent the way it is
now ? Thats if it wants to in the first place.

Alan
