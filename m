From: "Thibaut VARENE" <T-Bone@parisc-linux.org>
Subject: Re: [patch 2/9] tulip: NatSemi DP83840A PHY fix
Date: Thu, 27 Apr 2006 12:21:17 +0200
Message-ID: <7d01f9f00604270321y46baf76v2f334bc78c31c1a4@mail.gmail.com>
References: <200604270932.k3R9W4Xj025312@shell0.pdx.osdl.net>
	 <44509477.4010001@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: akpm@osdl.org, netdev@vger.kernel.org, grundler@parisc-linux.org,
	jgarzik@pobox.com, "Francois Romieu" <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0102.google.com ([64.233.162.199]:20458 "EHLO
	nz-out-0102.google.com") by vger.kernel.org with ESMTP
	id S965079AbWD0KVR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2006 06:21:17 -0400
Received: by nz-out-0102.google.com with SMTP id n1so1901674nzf
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2006 03:21:17 -0700 (PDT)
To: "Jeff Garzik" <jeff@garzik.org>
In-Reply-To: <44509477.4010001@garzik.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 4/27/06, Jeff Garzik <jeff@garzik.org> wrote:
> akpm@osdl.org wrote:
> > +                             if (startup) {
> > +                                     int timeout = 10;       /* max 1 ms */
> >                                       for (i = 0; i < reset_length; i++)
> >                                               iowrite32(get_u16(&reset_sequence[i]) << 16, ioaddr + CSR15);
> > +
> > +                                     /* flush posted writes */
> > +                                     ioread32(ioaddr + CSR15);
> > +
> > +                                     /* Sect 3.10.3 in DP83840A.pdf (p39) */
> > +                                     udelay(500);
> > +
> > +                                     /* Section 4.2 in DP83840A.pdf (p43) */
> > +                                     /* and IEEE 802.3 "22.2.4.1.1 Reset" */
> > +                                     while (timeout-- &&
> > +                                             (tulip_mdio_read (dev, phy_num, MII_BMCR) & BMCR_RESET))
> > +                                             udelay(100);
>
>
> What can we do about this?
>
> Its a huge delay to be taken inside a spinlock.

This is device setup code. ISTR Grant showing other similar examples
of delays in such code in the kernel. Unless you keep
configuring/deconfiguring the device, and assuming you hit worst case
scenario everytime, it won't be a problem. But if you're doing that,
you already have a problem elsewhere. Or am I missing something?

> Anybody interested to converting the driver to use schedule_work() or
> similar?

That question has been raised months ago without any significant
outcome. Maybe it's time to move on? This code does respect hardware
specs, at least, which isn't the case of existing code, and fixes a
bug...

HTH

T-Bone

--
Thibaut VARENE
http://www.parisc-linux.org/~varenet/
