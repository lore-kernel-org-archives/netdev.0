From: Jan Oravec <jan.oravec@6com.sk>
Subject: Re: IPv6/sparc64: icmp port unreachable corruption
Date: Sun, 9 Nov 2003 14:39:39 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031109133939.GA17333@wsx.ksp.sk>
References: <20031109122844.GA14241@wsx.ksp.sk> <20031109132552.GA17096@wsx.ksp.sk>
Reply-To: Jan Oravec <jan.oravec@6com.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, davem@redhat.com, yoshfuji@linux-ipv6.org
Content-Disposition: inline
In-Reply-To: <20031109132552.GA17096@wsx.ksp.sk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

And another observation is that on 2.6.0-test9-bk4 on Opteron x86_64 when I
do:

# traceroute6 ::1

The kernel crashs.

I will have kernel OOPS output tommorow (the box is located in office)



On Sun, Nov 09, 2003 at 02:25:53PM +0100, Jan Oravec wrote:
> This may be related to the problem (on sparc64):
> 
> # traceroute6 3ffe:80ee:3bd:0:a00:20ff:fec7:a192
> traceroute to 3ffe:80ee:3bd:0:a00:20ff:fec7:a192 (3ffe:80ee:3bd:0:a00:20ff:fec7:a192) from ::1, 30 hops max, 24 byte packets
> Bus error
> 
> # traceroute6 3ffe:80ee:3bd:0:a00:20ff:fec7:a192 -s 3ffe:80ee:3bd:0:a00:20ff:fec7:a192
> traceroute to 3ffe:80ee:3bd:0:a00:20ff:fec7:a192 (3ffe:80ee:3bd:0:a00:20ff:fec7:a192) from 3ffe:80ee:3bd:0:a00:20ff:fec7:a192, 30 hops max, 24 byte packets
> Bus error
> 
> # traceroute6 www.kame.net
> traceroute to orange.kame.net (2001:200:0:8002:203:47ff:fea5:3085) from 3ffe:80ee:3bd:0:a00:20ff:fec7:a192, 30 hops max, 24 byte packets
>  1  skbra-00-01.pop.xs26.net (3ffe:80ee:3bd:0:a00:20ff:fec9:3aad)  0.953 ms 0.305 ms  0.341 ms
> ...
> 
> The following lines are appearing in dmesg:
> raw v6 hw csum failure.
> 
> All of this worked fine in 2.4.22-pre6.
> 
> 
> The common problem of 2.4 and 2.6 is with IPv4 traceroute, but it is
> probably because of buggy 64-bit traceroute, because it worked fine in
> 32-bit userspace:
> 
> # traceroute www.google.com
> traceroute to www.google.akadns.net (216.239.57.99), 30 hops max, 52 byte packets
> Bus error
> 
> 
> 
> On Sun, Nov 09, 2003 at 01:28:44PM +0100, Jan Oravec wrote:
> > Hello,
> > 
> > 
> > I have found the following problem with 2.6.0-test9-bk13 on sparc64:
> > 
> > We do traceroute6 to 3ffe:80ee:3bd:0:a00:20ff:fec7:a192 (IP of that
> > sparc64). We get the following corrupted answer:
> > 
> > 13:17:47.191547 3ffe:80ee:3bd:0:a00:20ff:fec7:a192 > 3ffe:80ee:a:0:201:3ff:fed5:bd1e: [|icmp6] (len 72, hlim 62)
> > 0x0000   6000 0000 0048 3a3e 3ffe 80ee 03bd 0000        ....H:>?.......
> > 0x0010   0a00 20ff fec7 a192 3ffe 80ee 000a 0000        ........?.......
> > 0x0020   0201 03ff fed5 bd1e 0104 aa7c 0000 0000        ...........|....
> > 0x0030   0000 0064 0000 0000 0100 0000 0100 0000        ...d............
> > 0x0040   aaaa aaaa aaaa aaaa 9680 c00b c622 7fec        ............."..
> > 0x0050   aaaa aaaa aaaa aaaa 9680 c00b c622 7ffc        ............."..
> > 0x0060   aaaa aaaa 0000 0000 8a10 2000 04c2 8049        ...............I
> > 
> > 
> > When doing exactly same to x86 box (with 2.6.0-test7-bk7 running), we get
> > the correct answer:
> > 
> > 13:17:31.140230 3ffe:80ee:1:0:204:76ff:fe97:d69a > 3ffe:80ee:a:0:201:3ff:fed5:bd1e: icmp6: 3ffe:80ee:1:0:204:76ff:fe97:d69a udp port 33434 unreachable (len 72, hlim 63)
> > 0x0000   6000 0000 0048 3a3f 3ffe 80ee 0001 0000        ....H:??.......
> > 0x0010   0204 76ff fe97 d69a 3ffe 80ee 000a 0000        ..v.....?.......
> > 0x0020   0201 03ff fed5 bd1e 0104 fb79 0000 0000        ...........y....
> > 0x0030   6000 0000 0018 1101 3ffe 80ee 000a 0000        .......?.......
> > 0x0040   0201 03ff fed5 bd1e 3ffe 80ee 0001 0000        ........?.......
> > 0x0050   0204 76ff fe97 d69a 8018 829a 0018 0c82        ..v.............
> > 0x0060   0000 1df3 0000 0005 5b30 ae3f 3512 0200        ........[0.?5...
> > 
> > 
> > Jan
> > 
> 
