From: jamal <hadi@cyberus.ca>
Subject: Re: [patch 4/10] s390: network driver.
Date: 16 Jan 2005 18:10:38 -0500
Message-ID: <1105917038.1091.1041.camel@jzny.localdomain>
References: <OFB7F7E23F.EFB88418-ONC1256F7E.0031769E-C1256F7E.003270AD@de.ibm.com>
	 <1104764710.1048.580.camel@jzny.localdomain>  <41DB26A6.2070008@pobox.com>
	 <1104895169.1117.63.camel@jzny.localdomain>  <41DC0931.80603@tpack.net>
	 <1105019912.2314.20.camel@jzny.localdomain>
	 <1105023972.3462.48.camel@tsc-6.cph.tpack.net>
	 <1105104757.1046.63.camel@jzny.localdomain>
	 <1105111605.3462.101.camel@tsc-6.cph.tpack.net>
	 <1105363092.1041.146.camel@jzny.localdomain>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>,
        Thomas Spatzier <thomas.spatzier@de.ibm.com>,
        "David S. Miller" <davem@davemloft.net>,
        Hasso Tepper <hasso@estpak.ee>,
        Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com,
        Paul Jakma <paul@clubi.ie>
Return-path: <netdev-bounce@oss.sgi.com>
To: Tommy Christensen <tommy.christensen@tpack.net>
In-Reply-To: <1105363092.1041.146.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Didnt see anymore discussion on this - have we given up on it?

cheers,
jamal

On Mon, 2005-01-10 at 08:18, jamal wrote:
> On Fri, 2005-01-07 at 10:26, Tommy Christensen wrote:
> > On Fri, 2005-01-07 at 14:32, jamal wrote:
> > > On Thu, 2005-01-06 at 10:06, Tommy Christensen wrote:
> 
> [..]
> 
> > > reseting qdisc could certainly be part of the device watchdog.
> > > Note that once the packets are drained, the next thing that will happen
> > > if device is stopped for a dev->timeout period is watchdog kicking in
> > > and flushing the DMA. So you could reset your qdisc there though i am
> > > not sure it will be needed with that patch.
> > 
> > Unfortunately the watchdog won't do this when carrier is off, which
> > is fair enough since the chip isn't hung as such.
> 
> We may have to kick the dog in that path as well then.
> 
> > So, we would need another method to flush out stale packets from
> > the DMA ring. Some drivers already do this themselves, and some won't
> > need it because they keep on running even when link is down.
> 
> kicking tx_timeout seems like the right thing to do until i looked at
> the drivers. Sigh. I just stared at a few drivers and it is not pleasant
> - and they mostly have the same theme (so you cant say they are
> inconsistent).
> Looking at e1000 for example is quiet interesting - it actually brings
> down then up the device ;-> This will both flash the dma and reset qdisc
> but also loose any static routes. It will also reschedule the device;-<
> So i am not so sure that the dog kicking in a minute later is a good
> thing at all. We may need a lot of janitorial work to cleanse the
> drivers - something jgarzik is against. 
> 
> A qdisc_reset, as you suggest, will probably not cure the problem but
> provide some cosmetics. Thoughts?
> 
> cheers,
> jamal
> 
> 
> 
