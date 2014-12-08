From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: wl1251: NVS firmware data
Date: Mon, 8 Dec 2014 15:57:21 -0500
Message-ID: <20141208205721.GA14895@kroah.com>
References: <201411271506.20457@pali>
 <CACVXFVPOLfDuqc0nLb-zM8vH618DLXy0xtZbUOn5_XvdxRZSDw@mail.gmail.com>
 <20141208163714.GA31169@kroah.com>
 <201412081747.30965@pali>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ming Lei <ming.lei@canonical.com>, Pavel Machek <pavel@ucw.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	Grazvydas Ignotas <notasas@gmail.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
	Aaro Koskinen <aaro.koskinen@iki.fi>,
	Kalle Valo <kvalo@adurom.com>,
	Sebastian Reichel <sre@ring0.de>,
	David Gnedt <david.gnedt@davizone.at>
To: Pali =?iso-8859-1?Q?Roh=E1r?= <pali.rohar@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201412081747.30965@pali>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 08, 2014 at 05:47:30PM +0100, Pali Roh=E1r wrote:
> On Monday 08 December 2014 17:37:14 Greg Kroah-Hartman wrote:
> > On Mon, Dec 08, 2014 at 11:18:18PM +0800, Ming Lei wrote:
> > > On Sat, Dec 6, 2014 at 9:02 PM, Pali Roh=E1r=20
> <pali.rohar@gmail.com> wrote:
> > > > On Saturday 06 December 2014 13:49:54 Pavel Machek wrote:
> > > >  /**
> > > >=20
> > > > + * request_firmware_prefer_user: - prefer usermode helper
> > > > for loading firmware + * @firmware_p: pointer to firmware
> > > > image
> > > > + * @name: name of firmware file
> > > > + * @device: device for which firmware is being loaded
> > > > + *
> > > > + * This function works pretty much like
> > > > request_firmware(), but it prefer + * usermode helper. If
> > > > usermode helper fails then it fallback to direct access.
> > > > + * Usefull for dynamic or model specific firmware data.
> > > > + **/
> > > > +int request_firmware_prefer_user(const struct firmware
> > > > **firmware_p, +                           const char
> > > > *name, struct device *device) +{
> > > > +       int ret;
> > > > +       __module_get(THIS_MODULE);
> > > > +       ret =3D _request_firmware(firmware_p, name, device,
> > > > +                               FW_OPT_UEVENT |
> > > > FW_OPT_PREFER_USER); +       module_put(THIS_MODULE);
> > > > +       return ret;
> > > > +}
> > > > +EXPORT_SYMBOL_GPL(request_firmware_prefer_user);
> > >=20
> > > I'd like to introduce request_firmware_user() which only
> > > requests firmware from user space, and this way is simpler
> > > and more flexible since we have request_firmware_direct()
> > > already.
> >=20
> > Why would a driver care about what program provides the
> > firmware?  It shouldn't at all, and we want to get rid of the
> > userspace firmware loader, not encourage drivers to use it
> > "exclusively" at all.
> >=20
>=20
> Do not remove it! Without userspace firmware loader it is=20
> impossible to load dynamic firmware files.

You should not be loading "dynamic" firmware files with the firmware
interface, as that's not a "firmware" file anymore, it's a "special
binary file that my driver needs to be created and sent into the
kernel."

Use your own custom usermode helper for stuff like this, not the
firmware interface.  But use a binary sysfs file if you want, that seem=
s
to make sense for it...

greg k-h
