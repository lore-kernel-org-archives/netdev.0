From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [PATCH] USB: net: Fix asix read transfer
	buffer allocations.
Date: Mon, 22 Oct 2007 19:29:03 +0200
Message-ID: <200710221929.04035.oliver@neukum.org>
References: <20071022155053.GA28526@ru.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org
To: linux-usb-devel@lists.sourceforge.net
Return-path: <linux-usb-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20071022155053.GA28526@ru.mvista.com>
Content-Disposition: inline
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-usb-devel>,
	<mailto:linux-usb-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-usb-devel>
List-Post: <mailto:linux-usb-devel@lists.sourceforge.net>
List-Help: <mailto:linux-usb-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-usb-devel>,
	<mailto:linux-usb-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: linux-usb-devel-bounces@lists.sourceforge.net
Errors-To: linux-usb-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Am Montag 22 Oktober 2007 schrieb Valentine Barshak:
> =A0static int asix_mdio_read(struct net_device *netdev, int phy_id, int l=
oc)
> =A0{
> =A0=A0=A0=A0=A0=A0=A0=A0struct usbnet *dev =3D netdev_priv(netdev);
> +=A0=A0=A0=A0=A0=A0=A0void *buf;
> =A0=A0=A0=A0=A0=A0=A0=A0u16 res;
> =A0
> =A0=A0=A0=A0=A0=A0=A0=A0mutex_lock(&dev->phy_mutex);
> =A0=A0=A0=A0=A0=A0=A0=A0asix_set_sw_mii(dev);
> +
> +=A0=A0=A0=A0=A0=A0=A0buf =3D kmalloc(2, GFP_KERNEL);

This is done under lock. Can you allocate the buffer once and reuse it?

	Regards
		Oliver


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
linux-usb-devel@lists.sourceforge.net
To unsubscribe, use the last form field at:
https://lists.sourceforge.net/lists/listinfo/linux-usb-devel
