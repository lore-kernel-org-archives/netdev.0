From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [PATCH RFC] ZyDAS ZD1211 USB-WLAN driver
Date: Sat, 10 Jun 2006 13:49:06 +0200
Message-ID: <200606101349.06498.oliver@neukum.org>
References: <44817083.508@gentoo.org> <200606040025.32275.oliver@neukum.org>
	<20060610112306.GA19198@p15091797.pureserver.info>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Daniel Drake <dsd@gentoo.org>, netdev@vger.kernel.org,
	linux-usb-devel@lists.sourceforge.net,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-usb-devel-bounces@lists.sourceforge.net>
To: Ulrich Kunitz <kune@deine-taler.de>
In-Reply-To: <20060610112306.GA19198@p15091797.pureserver.info>
Content-Disposition: inline
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-usb-devel>,
	<mailto:linux-usb-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=linux-usb-devel>
List-Post: <mailto:linux-usb-devel@lists.sourceforge.net>
List-Help: <mailto:linux-usb-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-usb-devel>,
	<mailto:linux-usb-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: linux-usb-devel-bounces@lists.sourceforge.net
Errors-To: linux-usb-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Am Samstag, 10. Juni 2006 13:23 schrieb Ulrich Kunitz:
> On 06-06-04 00:25 Oliver Neukum wrote:
> 
> > > > +static void disconnect(struct usb_interface *intf)
> > > > This is racy. It allows io to disconnected devices. You must take the
> > > > lock and set a flag that you test after you've taken the lock elsewhere.
> > > 
> > > Will fix, thanks.
> > 
> > You're welcome
> 
> Not so fast, because I don't know what to fix.
> 
> Actually there are two cases, when disconnect is called. The first

There are three cases. It can also be triggered by sysfs and usbfs.

> is, when the device is removed. The second is, when the kernel
> module is removed from the kernel. It should also be recognized
> that disconnect() must always succeed, so we have to ignore IO
> errors anyhow.

You can ignore IO errors in disconnect(). They are harmless.

> In the first case we don't need the IO and in the second case we
> have to do it, because otherwise, the device will not come up, if
> we load the driver again.
> 
> Testing shows, that doing the IO doesn't create a lot of issues,
> there are some errors reported, but that's it and the second case
> just works fine. So there doesn't appear a problem and even if
> want to be "clean", I would like to know, how to distinguish both
> cases without trying to do IO with the device.

The problem is not that you may do IO _during_ disconnect. You may
do IO _after_ disconnect, even if usbfs might already have claimed
the device. Disconnect() must either terminate ongoing IO or wait for
it to end. And it must make sure that there'll be no IO afterwards.

	Regards
		Oliver


_______________________________________________
linux-usb-devel@lists.sourceforge.net
To unsubscribe, use the last form field at:
https://lists.sourceforge.net/lists/listinfo/linux-usb-devel
