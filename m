From: Mika Liljeberg <mika.liljeberg@welho.com>
Subject: Re: 2.4.21+ - IPv6 over IPv4 tunneling b0rked
Date: 11 Jul 2003 03:04:29 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1057881869.3588.10.camel@hades>
References: <20030710154302.GE1722@zip.com.au>
	 <1057854432.3588.2.camel@hades>  <20030710233931.GG1722@zip.com.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
   pekkas@netcore.fi
Return-path: <netdev-bounce@oss.sgi.com>
To: CaT <cat@zip.com.au>
In-Reply-To: <20030710233931.GG1722@zip.com.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2003-07-11 at 02:39, CaT wrote:
> And having remembered /127 being mentioned as bad I changed the
> interface config to a netmask of /64. Dropped it and brought it
> up and it all works.
> 
> There's something fundamental about ipv6 netmasks that I just don't
> understand...

Well, the thing is that prefix:: is a special anycast address that
identifies a router on the link prefix::/n, where n is the prefix
length. You had configured a 127-bit link prefix, meaning that you had
only one valid unicast address (last bit == 1) in addition to the router
anycast address (last bit == 0).

Normally, IPv6 networks are supposed to use 64-bit on-link prefixes but
the implementation can be written in such a way that other prefix
lengths can be configured.

Setting your tunnel prefix to /64 is certainly the right thing to do. 

	MikaL
