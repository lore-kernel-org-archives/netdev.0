From: Pali =?utf-8?q?Roh=C3=A1r?= <pali.rohar@gmail.com>
Subject: Re: wl1251: NVS firmware data
Date: Mon, 8 Dec 2014 20:56:37 +0100
Message-ID: <201412082056.37353@pali>
References: <201411271506.20457@pali> <201412082036.14609@pali> <508290C6-B3D7-4E07-BE5E-EF6BDE568E92@holtmann.org>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart3380800.rBeIzVeWLx";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Dan Williams <dcbw@redhat.com>,
	"Greg Kroah-Hartman" <gregkh@linuxfoundation.org>,
	Ming Lei <ming.lei@canonical.com>, Pavel Machek <pavel@ucw.cz>,
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
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:42077 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753514AbaLHT4l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2014 14:56:41 -0500
In-Reply-To: <508290C6-B3D7-4E07-BE5E-EF6BDE568E92@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart3380800.rBeIzVeWLx
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable

On Monday 08 December 2014 20:46:07 Marcel Holtmann wrote:
> Hi Pali,
>=20
> >>>>>>>>>> On Saturday 06 December 2014 13:49:54 Pavel Machek
> >>>>>>>>>> wrote: /**
> >>>>>>>>>>=20
> >>>>>>>>>> + * request_firmware_prefer_user: - prefer usermode
> >>>>>>>>>> helper for loading firmware + * @firmware_p:
> >>>>>>>>>> pointer to firmware image
> >>>>>>>>>> + * @name: name of firmware file
> >>>>>>>>>> + * @device: device for which firmware is being
> >>>>>>>>>> loaded + *
> >>>>>>>>>> + * This function works pretty much like
> >>>>>>>>>> request_firmware(), but it prefer + * usermode
> >>>>>>>>>> helper. If usermode helper fails then it fallback
> >>>>>>>>>> to direct access. + * Usefull for dynamic or model
> >>>>>>>>>> specific firmware data. + **/
> >>>>>>>>>> +int request_firmware_prefer_user(const struct
> >>>>>>>>>> firmware **firmware_p, +
> >>>>>>>>>> const char *name, struct device *device) +{
> >>>>>>>>>> +       int ret;
> >>>>>>>>>> +       __module_get(THIS_MODULE);
> >>>>>>>>>> +       ret =3D _request_firmware(firmware_p, name,
> >>>>>>>>>> device, +
> >>>>>>>>>> FW_OPT_UEVENT
> >>>>>>>>>>=20
> >>>>>>>>>> | FW_OPT_PREFER_USER); +
> >>>>>>>>>>=20
> >>>>>>>>>> module_put(THIS_MODULE); +       return ret;
> >>>>>>>>>> +}
> >>>>>>>>>> +EXPORT_SYMBOL_GPL(request_firmware_prefer_user);
> >>>>>>>>>=20
> >>>>>>>>> I'd like to introduce request_firmware_user() which
> >>>>>>>>> only requests firmware from user space, and this
> >>>>>>>>> way is simpler and more flexible since we have
> >>>>>>>>> request_firmware_direct() already.
> >>>>>>>>=20
> >>>>>>>> Why would a driver care about what program provides
> >>>>>>>> the firmware?  It shouldn't at all, and we want to
> >>>>>>>> get rid of the userspace firmware loader, not
> >>>>>>>> encourage drivers to use it "exclusively" at all.
> >>>>>>>=20
> >>>>>>> Do not remove it! Without userspace firmware loader it
> >>>>>>> is impossible to load dynamic firmware files.
> >>>>>>=20
> >>>>>> why is this dynamic in the first place. It does not
> >>>>>> sound like dynamic data to me at all. This is like the
> >>>>>> WiFi MAC address(es) or Bluetooth BD_ADDR. They are
> >>>>>> all static information. The only difference is that
> >>>>>> they are on the host accessibly filesystem or storage
> >>>>>> and not on the device itself.
> >>>>>>=20
> >>>>>> To be honest, for Bluetooth we solved this now. If the
> >>>>>> device is missing key information like the calibration
> >>>>>> data or BD_ADDR, then it comes up unconfigured. A
> >>>>>> userspace process can then go and load the right data
> >>>>>> into it and then the device becomes available as
> >>>>>> Bluetooth device.
> >>>>>>=20
> >>>>>> Trying to use request_firmware to load some random data
> >>>>>> and insist on going through userspace helper for that
> >>>>>> sounds crazy to me. Especially since we are trying
> >>>>>> hard to get away from the userspace loader. Forcing to
> >>>>>> keep it for new stuff sounds backwards to me.
> >>>>>>=20
> >>>>>> With the special Nokia partition in mind, why hasn't
> >>>>>> this been turned into a mountable filesystem or into a
> >>>>>> driver/subsystem that can access the data direct from
> >>>>>> the kernel. I advocated for this some time ago. Maybe
> >>>>>> there should be a special subsystem for access to
> >>>>>> these factory persistent information that drivers then
> >>>>>> just can access. I seem to remember that some systems
> >>>>>> provide these via ACPI. Why does the ARM platform has
> >>>>>> to be special here?
> >>>>>>=20
> >>>>>> And the problem of getting Ethernet and WiFi MAC
> >>>>>> address and Bluetooth BD_ADDR comes up many many
> >>>>>> times. Why not have something generic here. And don't
> >>>>>> tell me request_firmware is that generic solution ;)
> >>>>>>=20
> >>>>>> Regards
> >>>>>>=20
> >>>>>> Marcel
> >>>>>=20
> >>>>> Hi Marcel. I think you did not understand this problem.
> >>>>> This discussion is not about mac address. Please read
> >>>>> email thread again and if there are some unclear pars,
> >>>>> then ask. Thanks!
> >>>>=20
> >>>> I think that I pretty clearly understand the problem.
> >>>> Calibration data, MAC address, what is the difference?
> >>>> For me this is all the same. It is data that is specific
> >>>> to a device or type of devices and it is stored
> >>>> somewhere else. In most cases in some immutable
> >>>> memory/flash area.
> >>>=20
> >>> Those calibration data (in form of binary NVS firmware
> >>> file) needs to be sent to wl1251 chip. Mac address is not
> >>> needed at this step (and kernel generate some random if
> >>> is not provided).
> >>>=20
> >>> (Just to note wl1271 driver loads both MAC address and NVS
> >>> data via one firmware file which is prepared by userspace,
> >>> but this discussion is about wl1251...)
> >>>=20
> >>>> What you want is access to this data since the kernel
> >>>> driver needs it. Do I get this so far ;)
> >>>=20
> >>> Yes, we need to provide NVS data to kernel when kernel ask
> >>> for them.
> >>>=20
> >>>> So my take is that request_firmware is not the right way
> >>>> to get this data. Or more precisely make sure that this
> >>>> data is available to kernel drivers. And what I am seeing
> >>>> here is that instead of actually solving the bigger
> >>>> problem, we just hack around it with request_firmware.
> >>>> Now surprisingly the request_firmware loads files
> >>>> directly from the kernel and all the hacks do not work
> >>>> anymore.
> >>>>=20
> >>>> Regards
> >>>>=20
> >>>> Marcel
> >>>=20
> >>> Just read emails again...
> >>>=20
> >>> Our problem is:
> >>>=20
> >>> linux-firmware.git tree provides two binary firmware
> >>> files:
> >>>=20
> >>> ti-connectivity/wl1251-fw.bin
> >>> ti-connectivity/wl1251-nvs.bin
> >>>=20
> >>> First is firmware file, second NVS file with generic
> >>> calibration data. Kernel driver wl1251 now loads both
> >>> firmware files via request_firmware. Generic calibration
> >>> data are enough for wl1251 chip (it should work). But
> >>> devices have own calibration data stored somewhere else.
> >>>=20
> >>> On Nokia N900 NVS data are generated on-the-fly from some
> >>> bytes from CAL (/dev/mtd1), from state of cellular network
> >>> and from some other regulation settings.
> >>>=20
> >>> So I think that files stored in linux-firmware.git tree
> >>> (which are also installed into /lib/firmware/) should be
> >>> loaded with request_firmware function. Or not? Do you
> >>> think something else? What other developers think?
> >>>=20
> >>> I'm against kernel driver for CAL (/dev/mtd1) for more
> >>> reasons:
> >>>=20
> >>> 1) we have userspace open source code, but licensed under
> >>> GPLv3. And until kernel change license, we cannot include
> >>> it.
> >>>=20
> >>> 2) NVS data are (probably) not in one place, plus they
> >>> depends on something other.
> >>>=20
> >>> 3) If manufacture XYZ create new device with its own
> >>> storage format of calibration data this means that
> >>> correct solution for XYZ is also to implement new kernel
> >>> fs driver for its own format. Do you really want to have
> >>> in kernel all those drivers for all different
> >>> (proprietary) storage formats?
> >>>=20
> >>> 4) It does not help us with existence of generic file
> >>> /lib/firmware/ti-connectivity/wl1251-nvs.bin which comes
> >>> from linux-firmware.git tree.
> >>=20
> >> a) change driver to prefer a new "wl1251-nvs-n900.bin"
> >> file,
> >=20
> > Why to "*-n900.bin" ? wl1251 driver is used on other devices
> > too.
> >=20
> >> but fall back to "wl1251-nvs.bin" if the first one isn't
> >> present
> >>=20
> >> b) have a "wl1251-cal-nvs-update" service that, if
> >> wl1521-nvs-n900.bin is *not* present mounts the CAL MTD,
> >> reads the data, writes it out into wl1521-nvs-n900.bin, and
> >> the rmmod/modprobes the driver
> >=20
> > Quote:
> >> On Nokia N900 NVS data are generated on-the-fly from some
> >> bytes from CAL (/dev/mtd1), from state of cellular network
> >> and from some other regulation settings.
> >=20
> > This basically means to rewrite it every boot or everytime
> > when country was changed (for regulation settings). And Ii
> > really do not want to do that.
> >=20
> > And rmmod is not working on statically linked drivers into
> > zImage. So this is not solution.
>=20
> actually module removal is still considered a race condition.
> If re-loading a module is part of your solution, then you are
> already heading into the wrong direction.
>=20

No, I'm not doing it and I want to have driver still loaded.

> WiFi subsystem have a solution for handling regulatory
> enforcement. I don't know why would you try to invent that
> same via NVS files.
>=20

Both firmware and NVS files are sent to chip as blob data. And=20
they are sent every time when userspace ask to bring interface=20
up.

So looks like modprobing driver works without data. Kernel ask=20
for them once userspace want to use wifi network.

> >> and done?  Stuff that's not N900 just wouldn't ship the
> >> update service and would proceed like none of this
> >> happened.
> >>=20
> >> Dan
> >=20
> > Again, what is wrong with userspace firmware helper? I think
> > that it fix this problem in a clean way without any hacks
> > (like CAL in kernel or creating new FS specially for
> > parsing NVS and so on) in kernel. And in userspace we can
> > implement program which generate NVS firmware data
> > on-the-fly and send them to kernel in compatible format of
> > ti-connectivity/wl1251-nvs.bin
>=20
> How do you run a userspace firmware helper if the root
> filesystem has not yet been mounted? How do you run userspace
> helper during resume?
>=20

I cannot do that.

> Honestly for drivers linked statically into the kernel, the
> best approach is that they stay unconfigured until userspace
> is available and can run a tool to provide the correct data.
>=20
> Regards
>=20
> Marcel

So ifconfig wlan0 should fail? In our case for wl1251 I think we=20
should fallback to generic NVS data if are available (and maybe=20
later when request will be there again, userspace can provide=20
data).

=2D-=20
Pali Roh=C3=A1r
pali.rohar@gmail.com

--nextPart3380800.rBeIzVeWLx
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iEYEABECAAYFAlSGAnUACgkQi/DJPQPkQ1LB8ACgx4huc1oWxmvIGLtdgZjn+77c
TyMAnj5CI9+kiXEzYHc3LwWfjmKqQtsx
=ZBz0
-----END PGP SIGNATURE-----

--nextPart3380800.rBeIzVeWLx--
