From: bert hubert <ahu@ds9a.nl>
Subject: ip6sec broken *differently* in 2.5.66 :-)
Date: Tue, 25 Mar 2003 12:27:05 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030325112705.GA9793@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Alexey, thanks for the work on ip6sec but it still does slightly the wrong
thing here.

snapcount:~# ping6 -s 1406 deef.ds9a.nl

43.14 snapcount.ipv6.ds9a.nl > deef.ds9a.nl:
	AH(spi=0x00003d54,sumlen=16,seq=0x1e7): ESP(spi=0x00003d55,seq=0x1e7) 
	[hlim 0] (len 1456)
43.14 deef.ds9a.nl > snapcount.ipv6.ds9a.nl: icmp6: 
	echo reply (len 1414, hlim 64)

If I make the ping one byte bigger, nothing gets sent out! This goes on
until ping6 -s 1452, and then suddenly with ping6 -s 1453:

43.57 snapcount.ipv6.ds9a.nl > deef.ds9a.nl:
	AH(spi=0x00003d54,sumlen=16,seq=0x327): ESP(spi=0x00003d55,seq=0x327) 
	[hlim 0] (len 64)

Like the first segment didn't make it. If I further increase the pingsize to
-s 1455, this happens:

34.02 snapcount.ipv6.ds9a.nl > deef.ds9a.nl:
	AH(spi=0x00003d54,sumlen=16,seq=0x409): ESP(spi=0x00003d55,seq=0x409) 
	[hlim 0] (len 72)

Anything I can do to help, let me know.

Thanks.
-- 
http://www.PowerDNS.com      Open source, database driven DNS Software 
http://lartc.org           Linux Advanced Routing & Traffic Control HOWTO
http://netherlabs.nl                         Consulting
