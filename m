From: Simon Kelley <simon@thekelleys.org.uk>
Subject: Re: ipv6 and ipv4 interaction weirdness
Date: Fri, 11 Mar 2005 14:21:02 +0000
Message-ID: <4231A94E.9020904@thekelleys.org.uk>
References: <20050311121655.GE14146@zip.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
	pekkas@netcore.fi, yoshfuji@linux-ipv6.org
To: CaT <cat@zip.com.au>
In-Reply-To: <20050311121655.GE14146@zip.com.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

CaT wrote:
> I just had some issues with ssh and trying to get it to bind to all ipv6
> and ipv4 addresses to it via :: and 0.0.0.0. The problem was that it'd
> only let one succeed. If 0.0.0.0:22 was successful then :: port 22 could
> not happen and neither could my ipv6 addy port 22 as it would get the
> 'address already in use' error from bind(). The reverse was also true.
> If it bound to :: port 22 then 0.0.0.0:22 would fail.
> 
> On the other hand if I got it to bind to each address individually then
> both ipv4 (2 addresses) and ipv6 (1 address) binds would succeed.
> 
> Maybe I'm just looking at it wrong but shouldn't ipv4 and ipv6 interfere
> with each other?
> 
> I'm using kernel 2.6.11-ac2 with OpenSSH_3.8.1p1 Debian-8.sarge.4,
> OpenSSL 0.9.7e 25 Oct 2004 and glibc 2.3.2 (debian version
> 2.3.2.ds1-20).
> 

A solution is to set the IPV6_V6ONLY sockopt on the IPv6 socket (or just 
use IPv6 sockets and their ability to accept IPv4 connections in a 
corner of the IPv6 address space).

It seems unlikely that a released ssh would have that problem, but I 
haven't checked.

Cheers,

Simon.
