From: "Leonid Grossman" <leonid.grossman@s2io.com>
Subject: RE: The ultimate TOE design
Date: Thu, 16 Sep 2004 06:10:42 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200409161310.i8GDAnqG005123@guinness.s2io.com>
References: <20040916062033.GB12915@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "'John Heffner'" <jheffner@psc.edu>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'Andi Kleen'" <ak@suse.de>, "'David S. Miller'" <davem@davemloft.net>
In-Reply-To: <20040916062033.GB12915@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

 

> -----Original Message-----
> From: Andi Kleen [mailto:ak@suse.de] 
> Sent: Wednesday, September 15, 2004 11:21 PM
> To: David S. Miller
> Cc: John Heffner; netdev@oss.sgi.com; leonid.grossman@s2io.com
> Subject: Re: The ultimate TOE design
> 
> On Wed, Sep 15, 2004 at 02:46:24PM -0700, David S. Miller wrote:
> > On Wed, 15 Sep 2004 17:36:18 -0400 (EDT) John Heffner 
> > <jheffner@psc.edu> wrote:
> > 
> > > The other (much nicer) solution to case (b) is to just 
> USE A BIGGER MTU.
> > > 1500 bytes is ridiculously small.  Even with a 9k MTU, 
> the benefits 
> > > of TOE or TSO are nearly vanishing.  Those who say they 
> require high 
> > > performance, but are unwilling to buy or produce networking gear 
> > > with an MTU larger than 1500 bytes probably deserve what they get.
> > 
> > TSO gives a kind of virtual 64K MTU, FWIW.  But I do see your point.
> 
> We still need to solve the same problem for RX though.
> 
> -Andi

Ditto.

We can dream about benefits of huge MTUs, but the reality is that moving
beyond 9k MTU is years away. Reasons - mainly infrastructure, plus MTU above
~10k may loose checksum protection (granted, this depends whether the errors
are simple or complex, and also this may not be a showstopper for some
people).
Even 9k MTU is very far from being universally accepted, eight years after
our Alteon spec went out :-).
TSO works great for the transmit side (even for 9k MTU, the impact is not
insignificant), but RX problem that Andi is talking about is a major issue
for a lot of users.

I don't have hard data yet, but the expectations are that the effect of
doing "RX side TSO" will be close to having 64k RX MTU - I'll publish some
numbers once we bring up first Unix drivers with this feature and do some
measurements.

Leonid

> 
