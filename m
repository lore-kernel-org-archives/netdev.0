From: Octave <oles@ovh.net>
Subject: Re: NAPI 8139too.c for 2.4.23
Date: Tue, 2 Dec 2003 00:00:13 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031201230013.GM4313@ovh.net>
References: <20031201205038.GK10711@ovh.net> <20031201205533.GA15846@gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com,
        linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20031201205533.GA15846@gtf.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Is there any chance you could do some benchmark runs with ttcp or
> somesuch?

I tested on 6-7 servers running with 
eepro eth0: Intel Corp. 82557/8/9 [Ethernet Pro 100], 00:E0:18:01:78:6C, IRQ 10.
realtek 8139too with NAPI 8139too Fast Ethernet driver 0.9.27 
realtek 8139too with no NAPI (standard driver with soft polling)

If this quick test is correct, realtek 8139too's driver works as good as
eepro's driver. 

Octave 

>> from realtek (no NAPI) to realtek (no NAPI)
ttcp-r: buflen=8192, nbuf=2048, align=16384/0, port=5001  tcp
ttcp-r: socket
ttcp-r: accept from
ttcp-r: 327680000 bytes in 42.90 real seconds = 59671.99 Kbit/sec +++
ttcp-r: 224852 I/O calls, msec/call = 0.20, calls/sec = 5241.16
ttcp-r: 0.1user 1.5sys 0:42real 3% 0i+0d 0maxrss 0+2pf 0+0csw  

>> from eepro to eepro
ttcp-r: buflen=8192, nbuf=2048, align=16384/0, port=5001  tcp
ttcp-r: socket
ttcp-r: accept from
ttcp-r: 327680000 bytes in 28.33 real seconds = 90379.31 Kbit/sec +++
ttcp-r: 225058 I/O calls, msec/call = 0.13, calls/sec = 7945.54
ttcp-r: 0.2user 4.2sys 0:28real 15% 0i+0d 0maxrss 0+2pf 0+0csw 

>> from realtek (NAPI) to realtek (NAPI)
ttcp-r: buflen=8192, nbuf=2048, align=16384/0, port=5001  tcp
ttcp-r: socket
ttcp-r: accept from
ttcp-r: 327680000 bytes in 29.21 real seconds = 87644.11 Kbit/sec +++
ttcp-r: 225735 I/O calls, msec/call = 0.13, calls/sec = 7728.26
ttcp-r: 0.0user 1.7sys 0:29real 6% 0i+0d 0maxrss 0+2pf 0+0csw  

>> from eepro to realtek (no NAPI)
ttcp-r: buflen=8192, nbuf=2048, align=16384/0, port=5001  tcp
ttcp-r: socket
ttcp-r: accept from
ttcp-t: 327680000 bytes in 34.32 real seconds = 74594.99 Kbit/sec +++
ttcp-t: 40000 I/O calls, msec/call = 0.88, calls/sec = 1165.55
ttcp-t: 0.0user 1.2sys 0:34real 3% 0i+0d 0maxrss 0+2pf 0+0csw

>> from realtek (NAPI) to realtek (no NAPI)
ttcp-r: buflen=8192, nbuf=2048, align=16384/0, port=5001  tcp
ttcp-r: socket
ttcp-r: accept from
ttcp-r: 327680000 bytes in 32.60 real seconds = 78532.74 Kbit/sec +++
ttcp-r: 225544 I/O calls, msec/call = 0.15, calls/sec = 6918.98
ttcp-r: 0.1user 1.6sys 0:32real 5% 0i+0d 0maxrss 0+2pf 0+0csw

>> from realtek (NAPI) to eepro
ttcp-r: buflen=8192, nbuf=2048, align=16384/0, port=5001  tcp
ttcp-r: socket
ttcp-r: accept from
ttcp-r: 327680000 bytes in 34.02 real seconds = 75250.05 Kbit/sec +++
ttcp-r: 225685 I/O calls, msec/call = 0.15, calls/sec = 6633.91
ttcp-r: 0.1user 3.7sys 0:34real 11% 0i+0d 0maxrss 0+2pf 0+0csw
