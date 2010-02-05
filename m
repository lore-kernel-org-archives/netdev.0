From: "Kevin Pedretti" <ktpedre@sandia.gov>
Subject: Re: [PATCH] seastar - SeaStar Ethernet driver
Date: Thu, 4 Feb 2010 17:59:23 -0700
Message-ID: <1265331563.23523.100.camel@hawkeye.sandia.gov>
References: <20100202205845.GE5246@hawkeye.sandia.gov>
 <20100202.134251.15604523.davem@davemloft.net>
 <1265160242.15726.20.camel@hawkeye.sandia.gov>
 <20100202.174045.135005544.davem@davemloft.net>
 <1265324464.23523.51.camel@hawkeye.sandia.gov>
 <20100204231621.7a13695a@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Alan Cox" <alan@lxorguk.ukuu.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100204231621.7a13695a@lxorguk.ukuu.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2010-02-04 at 16:16 -0700, Alan Cox wrote:
> - tcpdump etc once coaxed would display seastar frames not fake ethernet
> - the config tools would actually report what it really was
> - non IP layers and userspace won't keep trying to do things you don't
>   want (what does it do right now with vlans I wonder 8))
> - there will be no ARP confusion
> 
> If it wants to stay compatible and pretend to be ethernet you probably
> need a message type for "encapsulated ethernet", you can then encapsulate
> anything not IP and stay compatible by keeping IP sent the way it is
> now ? Thats if it wants to in the first place.

I agree the current situation is rather confusing and a lot or most of
the standard tools will break.  I have used tcpdump with some success,
but I'm sure there's lots of stuff broken.

We do need to stay compatible with the existing proprietary driver.  The
usage model we're after is leaving all of the service nodes (nodes users
login to, serve I/O, etc.) booted with the existing proprietary software
and rebooting the compute nodes (99% of the nodes) with a modern Linux
kernel running this open-source seastar driver.  The compute nodes need
to be able to communicate with each other and with the service nodes
using IP (point-to-point).  Users login to the service nodes and then,
for example, can ssh to compute nodes, scp files to compute nodes,
etc.  

Probably critical background: each service node and each compute node
has a seastar NIC that directly connects to nearest neighbors, forming a
3-D torus.  The only way for the nodes to communicate is via this
network. 

I like the idea of encapsulating whole ethernet frames in a new message
type.  But won't the lack of broadcast (and multi-cast) still be an
issue for most protocols?  I also don't have much control over the
seastar header, but can probably find an ignored bit somewhere to mark
the new message type.

Kevin
