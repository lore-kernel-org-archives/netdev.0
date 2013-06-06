From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [PATCH] usbnet: improve/fix status interrupt endpoint interval
Date: Thu, 06 Jun 2013 10:07:53 +0200
Message-ID: <1596215.OGj7DxpsL0@linux-5eaq.site>
References: <20130604182830.GA13186@rhlx01.hs-esslingen.de> <CACVXFVOYMGjGLmyGy=pQwkcuFshLmdNcLZKfqUDazge45GMBPA@mail.gmail.com> <20130605163426.GA18818@rhlx01.hs-esslingen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Ming Lei <ming.lei@canonical.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	OndrejZary <linux@rainbow-software.org>
To: Andreas Mohr <andi@lisas.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130605163426.GA18818@rhlx01.hs-esslingen.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 05 June 2013 18:34:26 Andreas Mohr wrote:
> Hi,
> 
> On Wed, Jun 05, 2013 at 09:22:25AM +0800, Ming Lei wrote:
> > On Wed, Jun 5, 2013 at 2:28 AM, Andreas Mohr <andi@lisas.de> wrote:

> > >   Value 8 now managed to reduce powertop wakeups from ~ 540 to ~ 155
> > 
> > It means that your device only returns current link status instead of link
> > change. IMO, it isn't a good behaviour for the device.
> 
> I don't quite understand that.
> The way I see it is that there's the "20 times same value" averaging,
> and once that was successful, a link change gets communicated
> (usbnet_link_change()). Thus that merely results in a *delay*
> in signalling the link change...

The device should not deliver data unless the connection state has
changed. Unless your connection is incredibly flaky, your device also
delivers data on other occasions.
If no data is delivered, no interrupt will be raised. The original intent
of the code was to save bandwidth on the bus, not interrupt mitigation.

Yet, you tested it and it helps, so it is a good idea.

> I believe this number is meant to be a hard demand by the *device*,
> since a device is the authoritative party to know best about its
> own servicing requirements.
> Or, IOW, the thing that is a USB descriptor is to be seen as a *protocol*
> where a device signals its requirements (hopefully accurately, though!).
> And if it indicates a 1ms bInterval (which is "the requested maximum(!!)
> number of milliseconds between transaction attempts" [lvr usbfaq]),
> then one could argue that the servicing party (the kernel) damn well
> ought to follow through (unless it reliably knows that it can violate
> some parts of these demands without getting caught).

Yes, we hope to catch bogus values, but we need to be conservative.

	Regards
		Oliver
