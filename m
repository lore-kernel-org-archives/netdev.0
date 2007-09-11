From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH 3/3 v3] rfkill: Add rfkill documentation
Date: Tue, 11 Sep 2007 13:29:30 -0700
Message-ID: <20070911132930.88d1c588.randy.dunlap@oracle.com>
References: <200709101954.50852.IvDoorn@gmail.com>
	<200709101956.03861.IvDoorn@gmail.com>
	<200709111901.02137.IvDoorn@gmail.com>
	<200709112220.45382.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, Dmitry Torokhov <dtor@insightbb.com>,
	netdev@vger.kernel.org,
	Inaky Perez-Gonzalez <inaky@linux.intel.com>
To: Ivo van Doorn <ivdoorn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:57535 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752386AbXIKUah convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Sep 2007 16:30:37 -0400
In-Reply-To: <200709112220.45382.IvDoorn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 11 Sep 2007 22:20:45 +0200 Ivo van Doorn wrote:

> Add a documentation file which contains
> a short description about rfkill with some
> notes about drivers and the userspace interface.
>=20
> Changes since v1 and v2:
> =A0- Spellchecking
>=20
> Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>
> Acked-by: Dmitry Torokhov <dtor@mail.ru>

Thanks.
Acked-by: Randy Dunlap <randy.dunlap@oracle.com>

> ---
>=20
> Only patch 3 was updated, patches 1 and 2 remain the same.
>=20
>  Documentation/rfkill.txt |   89 ++++++++++++++++++++++++++++++++++++=
++++++++++
>  1 files changed, 89 insertions(+), 0 deletions(-)
>  create mode 100644 Documentation/rfkill.txt
>=20
> diff --git a/Documentation/rfkill.txt b/Documentation/rfkill.txt
> new file mode 100644
> index 0000000..a83ff23
> --- /dev/null
> +++ b/Documentation/rfkill.txt
> @@ -0,0 +1,89 @@
> +rfkill - RF switch subsystem support
> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> +
> +1 Implementation details
> +2 Driver support
> +3 Userspace support
> +
> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D
> +1: Implementation details
> +
> +The rfkill switch subsystem offers support for keys often found on l=
aptops
> +to enable wireless devices like WiFi and Bluetooth.
> +
> +This is done by providing the user 3 possibilities:
> + 1 - The rfkill system handles all events; userspace is not aware of=
 events.
> + 2 - The rfkill system handles all events; userspace is informed abo=
ut the events.
> + 3 - The rfkill system does not handle events; userspace handles all=
 events.
> +
> +The buttons to enable and disable the wireless radios are important =
in
> +situations where the user is for example using his laptop on a locat=
ion where
> +wireless radios _must_ be disabled (e.g. airplanes).
> +Because of this requirement, userspace support for the keys should n=
ot be
> +made mandatory. Because userspace might want to perform some additio=
nal smarter
> +tasks when the key is pressed, rfkill still provides userspace the p=
ossibility
> +to take over the task to handle the key events.
> +
> +The system inside the kernel has been split into 2 separate sections=
:
> +	1 - RFKILL
> +	2 - RFKILL_INPUT
> +
> +The first option enables rfkill support and will make sure userspace=
 will
> +be notified of any events through the input device. It also creates =
several
> +sysfs entries which can be used by userspace. See section "Userspace=
 support".
> +
> +The second option provides an rfkill input handler. This handler wil=
l
> +listen to all rfkill key events and will toggle the radio accordingl=
y.
> +With this option enabled userspace could either do nothing or simply
> +perform monitoring tasks.
> +
> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> +2: Driver support
> +
> +To build a driver with rfkill subsystem support, the driver should
> +depend on the Kconfig symbol RFKILL; it should _not_ depend on
> +RKFILL_INPUT.
> +
> +Unless key events trigger an interrupt to which the driver listens, =
polling
> +will be required to determine the key state changes. For this the in=
put
> +layer providers the input-polldev handler.
> +
> +A driver should implement a few steps to correctly make use of the
> +rfkill subsystem. First for non-polling drivers:
> +
> +	- rfkill_allocate()
> +	- input_allocate_device()
> +	- rfkill_register()
> +	- input_register_device()
> +
> +For polling drivers:
> +
> +	- rfkill_allocate()
> +	- input_allocate_polled_device()
> +	- rfkill_register()
> +	- input_register_polled_device()
> +
> +When a key event has been detected, the correct event should be
> +sent over the input device which has been registered by the driver.
> +
> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> +3: Userspace support
> +
> +For each key an input device will be created which will send out the=
 correct
> +key event when the rfkill key has been pressed.
> +
> +The following sysfs entries will be created:
> +
> +	name: Name assigned by driver to this key (interface or driver name=
).
> +	type: Name of the key type ("wlan", "bluetooth", etc).
> +	state: Current state of the key. 1: On, 0: Off.
> +	claim: 1: Userspace handles events, 0: Kernel handles events
> +
> +Both the "state" and "claim" entries are also writable. For the "sta=
te" entry
> +this means that when 1 or 0 is written all radios, not yet in the re=
quested
> +state, will be will be toggled accordingly.
> +For the "claim" entry writing 1 to it means that the kernel no longe=
r handles
> +key events even though RFKILL_INPUT input was enabled. When "claim" =
has been
> +set to 0, userspace should make sure that it listens for the input e=
vents or
> +check the sysfs "state" entry regularly to correctly perform the req=
uired
> +tasks when the rkfill key is pressed.
> --=20
> 1.5.3
>=20
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20


---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your cod=
e ***
