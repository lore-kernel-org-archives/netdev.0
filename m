From: bert hubert <ahu@ds9a.nl>
Subject: Re: TCP/IPv6 broken in Linux 2.5.64?
Date: Tue, 18 Mar 2003 17:25:32 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030318162532.GA9705@outpost.ds9a.nl>
References: <20030318131104.GA16367@hensema.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Erik Hensema <erik@hensema.net>
Content-Disposition: inline
In-Reply-To: <20030318131104.GA16367@hensema.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Mar 18, 2003 at 02:11:04PM +0100, Erik Hensema wrote:
> Hi,
> 
> I'm trying to upgrade to Linux 2.5.x from 2.4.x. It seems to be working
> fine, except for IPv6: a TCP session can be established, but I can't send
> data. I can receive it though.

I can confirm this. 2.5.65 can connect to other hosts out there, like ipv6
irc servers, or an IPv6 zonetransfer. However, when I try to ssh from 2.5.65
to another 2.5.65, nothing happens.

2.4.18 can also ssh to 2.5.65.

So we have:

       to:	2.4.18	2.5.65
from:
2.4.18		  OK     OK
2.5.65  	  OK     ERROR


tcpdump from 2.5.65 to 2.5.65:

25.987220 hostA.33180 > hostB.22: S 2721590261:2721590261(0) win 5760
	<mss 1440,sackOK,timestamp 15005149 0,nop,wscale 0>

25.987490 hostB.22 > hostA.33180: S 2377513523:2377513523(0) 
	ack 2721590262 win 5712 
	<mss 1440,sackOK,timestamp 5200381 15005149,nop,wscale 0>

25.987622 hostA.33180 > hostB.22: . ack 1 win 5760 
	<nop,nop,timestamp 15005149 5200381>

25.993273 hostB.22 > hostA.33180: P 1:41(40) ack 1 win 5712 
	<nop,nop,timestamp 5200387 15005149>
26.193443 hostB.22 > hostA.33180: P 1:41(40) ack 1 win 5712 
	<nop,nop,timestamp 5200588 15005149>
26.757236 hostB.22 > hostA.33180: P 1:41(40) ack 1 win 5712 
	<nop,nop,timestamp 5201152 15005149>

The originating host does not ACK the received data, it appears. No IPSEC
is involved with this.

Regards,

bert

-- 
http://www.PowerDNS.com      Open source, database driven DNS Software 
http://lartc.org           Linux Advanced Routing & Traffic Control HOWTO
http://netherlabs.nl                         Consulting
