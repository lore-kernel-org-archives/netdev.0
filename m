From: Andreas Jellinghaus <aj@dungeon.inka.de>
Subject: Re: ipsec without interface
Date: 01 Jul 2003 15:33:24 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1057066404.4054.9.camel@simulacron>
References: <1054235787.605.21.camel@simulacron>
	 <20030701125808.GA19408@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@oss.sgi.com" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: bert hubert <ahu@ds9a.nl>
In-Reply-To: <20030701125808.GA19408@outpost.ds9a.nl>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2003-07-01 at 14:58, bert hubert wrote:
> On Thu, May 29, 2003 at 09:16:27PM +0200, Andreas Jellinghaus wrote:
> > sure, the simple configurations work fine with kernel 2.5.* ipsec.
> > But I miss the interface and things I did with it. How are these
> > setups supposed to work without an interface?
> > 
> > a) in iptables allow everything coming from ipsec0,
> >    allow only ssh and ipsec on eth0.
> 
> iptables can filter on ESP/AH presence.

the packet is seen once as ESP/AH and once as normal (e.g. TCP)
packet. where is the connection? how can you see that a packet
came in first as ESP/AH packet and was then decrypted, and did
not came in without ipsec?

with freeswan that was easy: drop everything, unless it is from
interface ipsec0. And you always new, packets from ipsec0 came
in with valid ipsec encryption, that was easy to make sure.

and now? use fwmark? even if that works, its not as easy.

> 
> > b) source address selection. put the default route on ipsec0,
> 
> Do you need a separate source address?

I'm a "road warrior", so the local wireless lan gives me a
192.168.* address. For my ipsec tunnel to $company gateway
I need get an official address assigned, so I can use that
to access the company network, or even the internet (if I don't
trust the local network, and don't want unencrypted connections
to the internet). I think such a setup will be quite common.

local lan			some nat	company gateway	
192.168.0.* <-> 192.168.0.1			<->  1.2.3.4
ipsec tunnel
1.2.3.5 		<->				1.2.3.4 

connetion will use 1.2.3.5 <-> 1.2.3.80 (e.g. company file server,
allowing access from 1.2.3.*).

ip route del default
ip route add default gw 192.168.0.1 src 1.2.3.5

yes, that works. but it's not nice.
also company getway needs a 
	ip route add 1.2.3.5 dev eth0/1/2/whatever
even though no packet to "1.2.3.5" will ever be on any
wire - the packet will be alway encrypted and have a final
ip address somewhere in the internet or wireless network.

hmm. I haven't tried to use an explicit ipip tunnel.
did anyone use ESP in transport mode to encrypt packets
of an IPIP tunnel? that might help me.

Regards, Andreas
