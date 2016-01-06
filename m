From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] net/rfkill: Create "airplane mode" LED trigger
Date: Tue, 5 Jan 2016 22:55:46 -0800
Message-ID: <6DC3AA8C-DDE9-44B8-91C5-94B1EB0DBE9A@holtmann.org>
References: <1451142303-1872-1-git-send-email-jprvita@endlessm.com> <1451142303-1872-2-git-send-email-jprvita@endlessm.com>
Mime-Version: 1.0 (Mac OS X Mail 9.2 \(3112\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	=?utf-8?Q?Jo=C3=A3o_Paulo_Rechi_Vita?= <jprvita@endlessm.com>
To: =?utf-8?Q?Jo=C3=A3o_Paulo_Rechi_Vita?= <jprvita@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1451142303-1872-2-git-send-email-jprvita@endlessm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Joao,

> For platform drivers to be able to correctly drive the "Airplane Mode=
"
> indicative LED there needs to be a RFKill LED trigger tied to the glo=
bal
> state of RFKILL_TYPE_ALL (instead of to a specific RFKill) and that
> works in an inverted manner of regular RFKill LED triggers, that is, =
the
> LED is ON when the state is blocked, and OFF otherwise.
>=20
> This commit implements such a trigger, which will be used by the
> asus-wireless x86 platform driver.
>=20
> Signed-off-by: Jo=C3=A3o Paulo Rechi Vita <jprvita@endlessm.com>
> ---
> net/rfkill/core.c | 30 ++++++++++++++++++++++++++++++
> 1 file changed, 30 insertions(+)
>=20
> diff --git a/net/rfkill/core.c b/net/rfkill/core.c
> index b41e9ea..3effc29 100644
> --- a/net/rfkill/core.c
> +++ b/net/rfkill/core.c
> @@ -124,6 +124,26 @@ static bool rfkill_epo_lock_active;
>=20
>=20
> #ifdef CONFIG_RFKILL_LEDS
> +static void airplane_mode_led_trigger_activate(struct led_classdev *=
led);
> +
> +static struct led_trigger airplane_mode_led_trigger =3D {
> +	.name     =3D "rfkill-airplane-mode",
> +	.activate =3D airplane_mode_led_trigger_activate,
> +};

so I am not convinced the kernel should have the concept of airplane mo=
de at all. It is kinda of a term that keeps changing since airlines do =
now allow WiFi and Bluetooth short range transmissions during flight. W=
e stayed away from calling it airplane mode since by the nature of it b=
eing governed by local regulations it will change over time.

The RFKILL subsystem got away with not labeling it by just saying RFKIL=
L_CHANGE_ALL and if we want a trigger for that action we better find a =
more general term to describe the fact that all RF devices are shut off=
=2E

Keep in mind that even with airplane mode on, you can re-activate Bluet=
ooth and WiFi these days. So while you are in airplane mode, then RFKIL=
L switches for these two technologies can be taken back off. If we want=
ed to model that in the kernel we would be putting policy in the kernel=
 and I think that is a bad idea.

That is pretty much the main reason why ConnMan never tried to push the=
 information about flight mode back into the kernel. It is not a policy=
 that the kernel can determine in the first place.

Regards

Marcel
