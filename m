From: "Ahmed S. Darwish" <darwish.07@gmail.com>
Subject: Re: [PATCH v4 4/4] can: kvaser_usb: Retry first bulk transfer on
 -ETIMEDOUT
Date: Mon, 12 Jan 2015 05:14:07 -0500
Message-ID: <20150112101407.GA9213@linux>
References: <20141223154654.GB6460@vivalin-002>
 <20150111200544.GA8855@linux>
 <20150111201116.GB8855@linux>
 <20150111201519.GC8855@linux>
 <20150111203612.GA8999@linux>
 <20150111204508.GB8999@linux>
 <54B2E23E.1090108@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Olivier Sobrie <olivier@sobrie.be>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Linux-USB <linux-usb@vger.kernel.org>,
	Linux-CAN <linux-can@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <54B2E23E.1090108@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jan 11, 2015 at 09:51:10PM +0100, Marc Kleine-Budde wrote:
> On 01/11/2015 09:45 PM, Ahmed S. Darwish wrote:
> > From: Ahmed S. Darwish <ahmed.darwish@valeo.com>
> > 
> > (This is a draft patch, I'm not sure if this fixes the USB
> > bug or only its psymptom. Feedback from the linux-usb folks
> > is really appreciated.)
> > 
> > When plugging the Kvaser USB/CAN dongle the first time, everything
> > works as expected and all of the transfers from and to the USB
> > device succeeds.
> > 
> > Meanwhile, after unplugging the device and plugging it again, the
> > first bulk transfer _always_ returns an -ETIMEDOUT. The following
> > behaviour was observied:
> > 
> > - Setting higher timeout values for the first bulk transfer never
> >   solved the issue.
> > 
> > - Unloading, then loading, our kvaser_usb module in question
> >   __always__ solved the issue.
> > 
> > - Checking first bulk transfer status, and retry the transfer
> >   again in case of an -ETIMEDOUT also __always__ solved the issue.
> >   This is what the patch below does.
> > 
> > - In the testing done so far, this issue appears only on laptops
> >   but never on PCs (possibly power related?)
> > 
> > Signed-off-by: Ahmed S. Darwish <ahmed.darwish@valeo.com>
> 
> Does this patch apply apply between 3 and 4? If not, please re-arrange
> the series. As this is a bug fix, patches 1, 2 and 4 will go via
> net/master, 3 will go via net-next/master.
> 

Since no one complained earlier, I guess this issue only affects
USBCAN devices. That's why I've based it above patch #3: adding
USBCAN hardware support.

Nonetheless, it won't do any harm for the current Leaf-only
driver. So _if_ this is the correct fix, I will update the commit
log, refactor the check into a 'do { } while()' loop, and then
base it above the Leaf-only net/master fixes on patch #1, and #2.

Any feedback on the USB side of things?

Thanks,
Darwish
