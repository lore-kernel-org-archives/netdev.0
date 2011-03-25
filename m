From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RFC] usbnet: use eth%d name for known ethernet devices
Date: Fri, 25 Mar 2011 17:43:54 +0100
Message-ID: <201103251743.54805.arnd@arndb.de>
References: <4D79F068.2080009@linaro.org> <201103251257.32714.arnd@arndb.de> <AANLkTikEJi7bg5GG3Ero_Poe9F6WiKo8rW+Y1KtxhQ4B@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Steve Calfee <stevecalfee@gmail.com>,
	Michal Nazarewicz <mnazarewicz@gmail.com>,
	Randy Dunlap <rdunlap@xenotime.net>,
	broonie@opensource.wolfsonmicro.com,
	lkml <linux-kernel@vger.kernel.org>,
	Nicolas Pitre <nicolas.pitre@linaro.org>,
	Greg KH <greg@kroah.com>,
	David Brownell <dbrownell@users.sourceforge.net>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>, grant.likely@secretlab.ca,
	Linux USB list <linux-usb@vger.kernel.org>,
	andy.green@linaro.org, netdev@vger.kernel.org,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	roger.quadros@nokia.com,
	Jaswinder Singh <jaswinder.singh@linaro.org>,
	patches@linaro.org
To: Alexey Orishko <alexey.orishko@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTikEJi7bg5GG3Ero_Poe9F6WiKo8rW+Y1KtxhQ4B@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 25 March 2011, Alexey Orishko wrote:
> On Fri, Mar 25, 2011 at 12:57 PM, Arnd Bergmann <arnd@arndb.de> wrote:
> >
> > That would be a different way of looking at it.  FLAG_POINTTOPOINT
> > describes what the device is (a USB cable connecting two hosts), and
> > that flag can be used for various things, where the only thing
> > we currently do is the netif naming.
> >
> 
> For example, cdc_ether and cdc-ncm drivers can be used in different use cases:
> a) when device terminates the IP traffic
> or
> b) where device is a wireless router.
> 
> In both cases ethernet frames are sent over usb cable and terminated
> in device (eth header stripped), so it is point-to-point link for ethernet, but
> looking from IP layer is not p2p link for case b).
> 
> Please, explain, based on your idea, do we set this flag in both cases or not?
> Do you want to use the same netif name for both use cases described above?
> 

Most importantly, I want to keep the current rules, so that nothing breaks
for existing users.

For cdc_ether and cdc-ncm devices, my patch always sets both FLAG_ETHER and
FLAG_POINTTOPOINT, because the driver has no way to find out which of the
two is actually there.

The usb-net core driver interprets this as meaning that it has to decide
for the name based on something else, and that happens to be the presence
of a globally assigned MAC address. I don't think that keying off the MAC
address here is a particularly good idea, but that's what the driver has
always done.

	Arnd
