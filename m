From: Mika Liljeberg <mika.liljeberg@welho.com>
Subject: Re: 2.4.21+ - IPv6 over IPv4 tunneling b0rked
Date: 11 Jul 2003 15:09:26 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1057925366.896.24.camel@hades>
References: <Pine.LNX.4.44.0307111446250.27865-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andre Tomt <andre@tomt.net>, linux-kernel@vger.kernel.org,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pekka Savola <pekkas@netcore.fi>
In-Reply-To: <Pine.LNX.4.44.0307111446250.27865-100000@netcore.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2003-07-11 at 14:48, Pekka Savola wrote:
> On 11 Jul 2003, Mika Liljeberg wrote:
> > Here's a valid use for subnet router anycase that isn't working.
> > Somebody asked me how to set up 6to4, so I did a little testing.
> > 
> > Doesn't work:
> > 
> > hades:~# ip route add ::/0 via 2002:c058:6301::
> > RTNETLINK answers: Invalid argument
> > 
> > Works:
> > 
> > hades:~# ip route add ::/0 via 2002:c058:6301::1
> > 
> > Unfortunately the first form is what I need:
> > 
> > hades:~# host -t AAAA 6to4.ipv6.funet.fi
> > 6to4.ipv6.funet.fi has AAAA address 2001:708:0:1::624
> > 6to4.ipv6.funet.fi has AAAA address 2002:c058:6301::
> 
> I think that in this particular case, if should have configured your 
> interface address with 2002:v4:addr::/16, of which subnet anycast router 
> address would be 2002::.

Ah ok. It *is* configured with a /16. As far as my host is concerned,
2002:c058:6301:: should be just a unicast address like any other, so
maybe there is a IID==0 check somewhere?

> > So apparently there really is an inappropriate subnet router anycast
> > sanity check. Please fix this!
> 
> This *may* be caused by another issue too: nexthop's must be given in the
> compatible "::192.88.99.1" format, not 2002:xxxx :-(
> 
> I sent a patch on over a year or so ago, but it didn't gain that much 
> enthusiasm..

I vote for fixing this too. :-)

	MikaL
