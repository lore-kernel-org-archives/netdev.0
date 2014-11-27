From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: wl1251: NVS firmware data
Date: Thu, 27 Nov 2014 07:16:55 -0800
Message-ID: <20141127151655.GB23064@kroah.com>
References: <201411271506.20457@pali>
 <CACVXFVMr8jH1ZzyPNG91VDK8DuVjQsHn9ks62sSNjOfUnNsURQ@mail.gmail.com>
 <201411271543.23527@pali>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ming Lei <ming.lei@canonical.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Grazvydas Ignotas <notasas@gmail.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Pavel Machek <pavel@ucw.cz>,
	Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
	Aaro Koskinen <aaro.koskinen@iki.fi>,
	Kalle Valo <kvalo@adurom.com>,
	Sebastian Reichel <sre@ring0.de>,
	David Gnedt <david.gnedt@davizone.at>
To: Pali =?iso-8859-1?Q?Roh=E1r?= <pali.rohar@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201411271543.23527@pali>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 27, 2014 at 03:43:23PM +0100, Pali Roh=E1r wrote:
> On Thursday 27 November 2014 15:21:44 Ming Lei wrote:
> > On Thu, Nov 27, 2014 at 10:06 PM, Pali Roh=E1r=20
> <pali.rohar@gmail.com> wrote:
> > > Hello,
> > >=20
> > > wifi driver wl1251 needs NVS calibration data for working.
> > > These data are loaded by driver via request_firmware from
> > > userspace file: ti-connectivity/wl1251-nvs.bin. In
> > > linux-fimrware git tree there is generic wl1251-nvs.bin
> > > file which is used by default.
> > >=20
> > > Driver wl1251 is used on Nokia N900 cellphone for its wifi
> > > chip. This cellphone has one special MTD partition (called
> > > CAL) where are stored some configuration data in special
> > > binary (key-value) format. And there is also stored correct
> > > calibration data for specific device (each device has
> > > different data). It is preferred to use those data instead
> > > generic one (provided by linux-firmware git tree).
> > >=20
> > > Now my question is: How to correctly load calibration data
> > > from special Nokia N900 CAL partition into wl1251 kernel
> > > driver?
> >=20
> > It is better to let user space script handle the request.
> >=20
>=20
> Yes, this makes sense. Implementing CAL parser in kernel wl1251=20
> driver would be hard...
>=20
> > > By default kernel reads ti-connectivity/wl1251-nvs.bin file
> > > from VFS if exists without any userspace support. If it
> > > fails then it fallback to loading via udev.
> >=20
> > You can remove or rename this file so that loading from user
> > space can be triggered.
> >=20
>=20
> It is no so easy... In case when CAL does not contains NVS data=20
> then we want to use this generic NVS file. And telling everybody=20
> to rename this is file is not good solution...

But that's up to your system configuration, not the kernel.  Make a
userspace package for the firmware that creates it in the format you
need it to be in, for the hardware you have, and then there would not b=
e
any need for a kernel change, right?

greg k-h
