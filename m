From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: Ambiguities in TCP/IP - firewall bypassing (fwd)
Date: Sat, 19 Oct 2002 14:38:56 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0210191437230.12141-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

See the thread on bugtraq.

Linux 2.4.19 initiates TCP handshake with SYN and RST bits set.  SYN with 
_RST_ seems like a total nonsense (SYN with FIN might even be useful for 
stuff like T/TCP) but I guess the spec didn't take any stance on that..

-- 
Pekka Savola                 "Tell me of difficulties surmounted,
Netcore Oy                   not those you stumble over and fall"
Systems. Networks. Security.  -- Robert Jordan: A Crown of Swords

---------- Forwarded message ----------
Date: Sat, 19 Oct 2002 01:03:47 +0200
From: Florian Weimer <Weimer@CERT.Uni-Stuttgart.DE>
To: Paul Starzetz <paul@starzetz.de>
Subject: Re: Ambiguities in TCP/IP - firewall bypassing

Paul Starzetz <paul@starzetz.de> writes:

> * Linux 2.4.19
>
> The examination of the source code of the TCP engine reveals that a
> TCP connection can be opened by any combination of the TCP flags
> having the SYN bit set and the ACK bit reset. For example we can open
> a TCP connection by sending an obviously bogus SYN,RST packet:
>
> 14:25:43.888897 192.168.1.184.12345 > 192.168.1.111.9999: SR
> 420:420(0) win 512 (DF) [tos 0x18]
> 14:25:43.889143 192.168.1.111.9999 > 192.168.1.184.12345: S
> 2168208394:2168208394(0) ack 421 win 5840 <mss 1460> (DF)

As a result of this bug, it's quite complicated (if not impossible in
some configurations) to properly filter connection attempts to Linux
hosts on Cisco IOS routers.

If your access list is a whitelist with a "permit tcp any any
established" statement somewhere, it's very likely that you can bypass
the filter just by setting the RST in the initial SYN packet, as
described above.  The router will forward the packet, and the Linux
host will happily initiate the three-way handshake.

"established" in Cisco parlance does not mean "SYN unset", but "ACK or
RST set".  This means that the impact for non-Linux hosts (which do
not react to SYN-RST packets according to Paul's survey) is less
severe if your filters run IOS.

-- 
Florian Weimer 	                  Weimer@CERT.Uni-Stuttgart.DE
University of Stuttgart           http://CERT.Uni-Stuttgart.DE/people/fw/
RUS-CERT                          fax +49-711-685-5898
