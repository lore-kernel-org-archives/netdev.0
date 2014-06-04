From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 0/10] use safer test on the result of find_first_zero_bit
Date: Wed, 4 Jun 2014 13:34:08 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D172571DB@AcuExch.aculab.com>
References: <1401872880-23685-1-git-send-email-Julia.Lawall@lip6.fr>
 <CAMuHMdXsoFUXj4jLMWN6NY7Um19KwWO9Rhx=9=gqWu_K5Ev2kQ@mail.gmail.com>
 <alpine.DEB.2.10.1406041137270.2441@hadrien>
 <063D6719AE5E284EB5DD2968C1650D6D1725705F@AcuExch.aculab.com>
 <alpine.DEB.2.10.1406041148590.2441@hadrien>
 <CAMuHMdXPBQTYA0c=1hkC7943-_J59TVSFaEKsfY1F2ogV=Ld+A@mail.gmail.com>
 <alpine.DEB.2.10.1406041258200.2441@hadrien>
 <CAMuHMdV2wP43Lxf-UtCum37HyMPSboRb6RLNTHzm_ZNOBeJR0g@mail.gmail.com>
 <alpine.DEB.2.10.1406041510520.2441@hadrien>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: linux-rdma <linux-rdma@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>,
	Linux Fbdev development list <linux-fbdev@vger.kernel.org>,
	Linux-sh list <linux-sh@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"ath10k@lists.infradead.org" <ath10k@lists.infradead.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	driverdevel <devel@driverdev.osuosl.org>,
	"iss_storagedev@hp.com" <iss_storagedev@hp.com>,
	scsi <linux-scsi@vger.kernel.org>,
	linux-s390 <linux-s390@vger.kernel.org>,
	"adi-buildroot-devel@lists.sourceforge.net"
	<adi-buildroot-devel@lists.sourceforge.net>,
	Arnd Bergmann <arnd@arndb.de>,
	"sebott@linux.vnet.ibm.com" <sebott@linux.vnet.ibm.com>
To: 'Julia Lawall' <julia.lawall@lip6.fr>,
	Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.10.1406041510520.2441@hadrien>
Content-Language: en-US
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall
> On Wed, 4 Jun 2014, Geert Uytterhoeven wrote:
> 
> > Hi Julia,
> >
> > On Wed, Jun 4, 2014 at 1:00 PM, Julia Lawall <julia.lawall@lip6.fr> wrote:
> > > OK, thanks.  I was only looking at the C code.
> > >
> > > But the C code contains a loop that is followed by:
> > >
> > >         if (!size)
> > >                 return result;
> > >         tmp = *p;
> > >
> > > found_first:
> > >         tmp |= ~0UL << size;
> > >         if (tmp == ~0UL)        /* Are any bits zero? */
> > >                 return result + size;   /* Nope. */
> > >
> > > In the first return, it would seem that result == size.  Could the second
> > > one be changed to just return size?  It should not hurt performance.
> >
> > "size" may have been changed between function entry and this line.
> > So you have to store it in a temporary.
> 
> Sorry, after reflection it seems that indeed size + result is always the
> original size, so it is actually all of the code that uses >= that is
> doing something unnecessary.  == for the failure test is fine.

There is nothing wrong with defensive coding.
The 'tmp |= ~0UL << size' ensures that the return value is 'correct'
when there are no bits set.
The function could have been defined so that this wasn't needed.

If you assume that the 'no zero bits' is unlikely, then checking the
return value from ffz() could well be slightly faster.
Not that anything is likely to notice.

	David



