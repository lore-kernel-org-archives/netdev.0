From: Phil Sutter <phil@nwl.cc>
Subject: Re: [iproute PATCH v2 2/2] ifcfg: Quote left-hand side of [ ]
 expression
Date: Fri, 18 Aug 2017 13:24:14 +0200
Message-ID: <20170818112414.GJ10864@orbyte.nwl.cc>
References: <20170817170932.24900-1-phil@nwl.cc>
 <20170817170932.24900-3-phil@nwl.cc>
 <063D6719AE5E284EB5DD2968C1650D6DD005A809@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:44003 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751597AbdHRLYQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 18 Aug 2017 07:24:16 -0400
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DD005A809@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 18, 2017 at 09:32:52AM +0000, David Laight wrote:
> From: Phil Sutter
> > Sent: 17 August 2017 18:10
> > This prevents word-splitting and therefore leads to more accurate error
> > message in case 'grep -c' prints something other than a number.
> > 
> > Signed-off-by: Phil Sutter <phil@nwl.cc>
> > ---
> >  ip/ifcfg | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/ip/ifcfg b/ip/ifcfg
> > index 083d9df36742f..30a2dc49816cd 100644
> > --- a/ip/ifcfg
> > +++ b/ip/ifcfg
> > @@ -131,7 +131,7 @@ noarp=$?
> > 
> >  ip route add unreachable 224.0.0.0/24 >& /dev/null
> >  ip route add unreachable 255.255.255.255 >& /dev/null
> > -if [ `ip link ls $dev | grep -c MULTICAST` -ge 1 ]; then
> > +if [ "`ip link ls $dev | grep -c MULTICAST`" -ge 1 ]; then
> 
> You could drag all these scripts into the 1990's by using $(...)
> instead of `...`.

That's a different kettle of fish IMO, using $() doesn't change the
situation this addresses:

| $ [ $(echo foo bar) -eq 0 ] && echo ok
| bash: [: too many arguments
| $ [ "$(echo foo bar)" -eq 0 ] && echo ok
| bash: [: foo bar: integer expression expected

Cheers, Phil
