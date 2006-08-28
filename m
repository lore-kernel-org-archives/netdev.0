From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [PATCH 5/10] rt2x00: Register initialization fixes
Date: Mon, 28 Aug 2006 22:15:18 +0200
Message-ID: <200608282215.18238.IvDoorn@gmail.com>
References: <200608271739.14166.IvDoorn@gmail.com> <20060828160834.GA14069@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.186]:45107 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1751426AbWH1UP1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Aug 2006 16:15:27 -0400
Received: by nf-out-0910.google.com with SMTP id o25so35591nfa
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2006 13:15:25 -0700 (PDT)
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060828160834.GA14069@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 28 August 2006 18:08, John W. Linville wrote:
> On Sun, Aug 27, 2006 at 05:39:14PM +0200, Ivo van Doorn wrote:
> > Various register initialization fixes to make the device work properly.
> > This will fix the RX/TX issue for rt61pci.
> > 
> > Signed-off-by Ivo van Doorn <ivdoorn@gmail.com>
> > 
> > ---
> > 
> > diff -rU3 wireless-dev-rt2x00-interface/drivers/net/wireless/d80211/rt2x00/rt2400pci.c wireless-dev-rt2x00-register/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
> > --- wireless-dev-rt2x00-interface/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-08-27 16:11:40.000000000 +0200
> > +++ wireless-dev-rt2x00-register/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-08-27 16:17:02.000000000 +0200
> > @@ -1192,11 +1192,7 @@
> >  	rt2x00_register_write(rt2x00dev, RXCSR0, reg);
> >  
> >  	rt2x00_register_write(rt2x00dev, MACCSR0, cpu_to_le32(0x00217223));
> > -
> > -	rt2x00_register_read(rt2x00dev, MACCSR1, &reg);
> > -	rt2x00_set_field32(&reg, MACCSR1_AUTO_TXBBP, 1);
> > -	rt2x00_set_field32(&reg, MACCSR1_AUTO_RXBBP, 1);
> > -	rt2x00_register_write(rt2x00dev, MACCSR1, reg);
> > +	rt2x00_register_write(rt2x00dev, MACCSR1, cpu_to_le32(0x00235518));
> >  
> >  	rt2x00_register_read(rt2x00dev, MACCSR2, &reg);
> >  	rt2x00_set_field32(&reg, MACCSR2_DELAY, 64);
> > diff -rU3 wireless-dev-rt2x00-interface/drivers/net/wireless/d80211/rt2x00/rt2500pci.c wireless-dev-rt2x00-register/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
> > --- wireless-dev-rt2x00-interface/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-08-27 16:12:03.000000000 +0200
> > +++ wireless-dev-rt2x00-register/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-08-27 16:17:56.000000000 +0200
> > @@ -1249,6 +1249,7 @@
> >  		return -EBUSY;
> >  
> >  	rt2x00_register_write(rt2x00dev, PWRCSR0, cpu_to_le32(0x3f3b3100));
> > +	rt2x00_register_write(rt2x00dev, PCICSR, cpu_to_le32(0x000003b8));
> >  
> >  	rt2x00_register_write(rt2x00dev, PSCSR0, cpu_to_le32(0x00020002));
> >  	rt2x00_register_write(rt2x00dev, PSCSR1, cpu_to_le32(0x00000002));
> > @@ -1272,12 +1273,11 @@
> >  	rt2x00_set_field32(&reg, RXCSR0_DISABLE_RX, 0);
> >  	rt2x00_register_write(rt2x00dev, RXCSR0, reg);
> >  
> > -	rt2x00_register_write(rt2x00dev, MACCSR0, cpu_to_le32(0x00213223));
> > +	rt2x00_register_write(rt2x00dev, GPIOCSR, cpu_to_le32(0x0000ff00));
> > +	rt2x00_register_write(rt2x00dev, TESTCSR, cpu_to_le32(0x000000f0));
> >  
> > -	rt2x00_register_read(rt2x00dev, MACCSR1, &reg);
> > -	rt2x00_set_field32(&reg, MACCSR1_AUTO_TXBBP, 1);
> > -	rt2x00_set_field32(&reg, MACCSR1_AUTO_RXBBP, 1);
> > -	rt2x00_register_write(rt2x00dev, MACCSR1, reg);
> > +	rt2x00_register_write(rt2x00dev, MACCSR0, cpu_to_le32(0x00213223));
> > +	rt2x00_register_write(rt2x00dev, MACCSR1, cpu_to_le32(0x00235518));
> >  
> >  	rt2x00_register_read(rt2x00dev, MACCSR2, &reg);
> >  	rt2x00_set_field32(&reg, MACCSR2_DELAY, 64);
> 
> Lots of magic numbers here...can we do something about that?

Only partially, there are currently a couple problems with:
 - Some of the above registers are documented, but there is however a main problem with current documentation from Ralink,
   not all register maps are correct. The driver indicates some other function for the register than our documentation claims.
 - The register not defined, the documentation gives no details and I cannot understand the meaning of the value from
   the original Ralink code. This is a main problem with the original code since its code contains a great deal of magical values,
   most have them have been analysed and its meaning or origin was determined. There are however still some magical values left.
 - In some other situations it is indeed possible to use the bitmaps as defined in the header,
   but those would not always explain the meaning of the value clearer (GPIOCSR is for example just a list of BIT0, BIT1, BIT2 etc).
 - Using the defines fom the headers and using the rt2x00_set_field32 would result in quite a lot of cpu_to_le32 calls,
   this would be a waste on big endian machines when the particular register is only used once.

I will go over the values again and see which ones can be made clearer with comments, and if using the
rt2x00_set/get_field32 can be used instead to make things clearer.

Ivo
