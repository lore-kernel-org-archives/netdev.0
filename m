From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [Fwd: Problem with dual IPv4/IPv6 connect]
Date: Fri, 19 Nov 2004 13:57:50 -0500 (EST)
Message-ID: <20041119.135750.63434487.yoshfuji@linux-ipv6.org>
References: <20041118184950.GB3972@real.com>
	<Pine.LNX.4.61.0411190904580.6216@netcore.fi>
	<20041119184328.GB3396@real.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pekkas@netcore.fi, davem@davemloft.net, netdev@oss.sgi.com,
        yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: tmarshall@real.com
In-Reply-To: <20041119184328.GB3396@real.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20041119184328.GB3396@real.com> (at Fri, 19 Nov 2004 10:43:29 -0800), Tom Marshall <tmarshall@real.com> says:

> > I'd suggest you resend it to netdev, but also attach a minimal, 
> > trivial test case .c file which allows anyone to easily experiment 
> > with the behaviour, test a fix, etc.
> 
> Recap of the issue:
> 
>   s = socket(AF_INET6, SOCK_STREAM, 0)
>   connect(s, [fec0::203:baff:fe88:5a15]:1554) => EINPROGRESS
>   Put socket in select's write set
>   Kernel sends TCPv6 SYN
>   Kernel receives ICMPv6 Time Exceeded (routing error)
>   Socket becomes writable
>   getsockopt(s, SO_ERROR) => EHOSTUNREACH
(*)
>   connect(s, [:ffff:192.168.168.241]:1554) => ECONNABORTED

At the point of (*), the state of socket if undefined.
you need to create another socket to connect another peer.

--yoshfuji
