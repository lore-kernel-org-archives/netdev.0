From: "David S. Miller" <davem@redhat.com>
Subject: Re: IPv6/sparc64: icmp port unreachable corruption
Date: Mon, 10 Nov 2003 21:46:03 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031110214603.0057e365.davem@redhat.com>
References: <20031109122844.GA14241@wsx.ksp.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Jan Oravec <jan.oravec@6com.sk>
In-Reply-To: <20031109122844.GA14241@wsx.ksp.sk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 9 Nov 2003 13:28:44 +0100
Jan Oravec <jan.oravec@6com.sk> wrote:

> We do traceroute6 to 3ffe:80ee:3bd:0:a00:20ff:fec7:a192 (IP of that
> sparc64). We get the following corrupted answer:
> 
> 13:17:47.191547 3ffe:80ee:3bd:0:a00:20ff:fec7:a192 > 3ffe:80ee:a:0:201:3ff:fed5:bd1e: [|icmp6] (len 72, hlim 62)
> 0x0000   6000 0000 0048 3a3e 3ffe 80ee 03bd 0000        ....H:>?.......
> 0x0010   0a00 20ff fec7 a192 3ffe 80ee 000a 0000        ........?.......
> 0x0020   0201 03ff fed5 bd1e 0104 aa7c 0000 0000        ...........|....
> 0x0030   0000 0064 0000 0000 0100 0000 0100 0000        ...d............
> 0x0040   aaaa aaaa aaaa aaaa 9680 c00b c622 7fec        ............."..
> 0x0050   aaaa aaaa aaaa aaaa 9680 c00b c622 7ffc        ............."..
> 0x0060   aaaa aaaa 0000 0000 8a10 2000 04c2 8049        ...............I

What specifically about this packet makes you think it is corrupted?

Let's look at the ICMP header you say is "correct" from the x86 box:

> 0104 fb79 0000 0000

type = ICMPV6_DEST_UNREACH
code = ICMPV6_PORT_UNREACH

In the sparc64 generated packet these two values are identical:

> 0104 aa7c 0000 0000

So why does tcpdump not say that this is "udp port XXX unreachable"
like it does for the x86 generated packet.

Incorrect checksum or corrupted payload after the icmp6 header?

What compiler are you using to build 2.6.x kernels btw?  We could
be looking at a miscompile here.

The bus error you reported from running traceroute6 on the sparc64
system is not that useful, can you use gdb or some other tool to
figure out where inside of tcpdump6 the bus error is occuring?  Is is
happening in the tcpdump6 program itself?  It is due to a failed system
call?

Thanks.
