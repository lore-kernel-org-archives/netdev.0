From: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
Subject: Re: [PATCH 2/3] net/fec: add device tree support
Date: Sat, 18 Jun 2011 18:24:38 -0600
Message-ID: <BANLkTimkT2G8v=hrzy0oB8Y0wfzc4jECuA@mail.gmail.com>
References: <1308410354-21387-1-git-send-email-shawn.guo@linaro.org>
	<1308410354-21387-3-git-send-email-shawn.guo@linaro.org>
	<201106182027.22974.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: patches-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	Jason Liu <jason.hui-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <201106182027.22974.arnd-r2nGTMty4D4@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Jun 18, 2011 at 12:27 PM, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org> wrote:
> On Saturday 18 June 2011 17:19:13 Shawn Guo wrote:
>> diff --git a/Documentation/devicetree/bindings/net/fsl-fec.txt b/Documen=
tation/devicetree/bindings/net/fsl-fec.txt
>> new file mode 100644
>> index 0000000..705111d
>> --- /dev/null
>> +++ b/Documentation/devicetree/bindings/net/fsl-fec.txt
>> @@ -0,0 +1,14 @@
>> +* Freescale Fast Ethernet Controller (FEC)
>> +
>> +Required properties:
>> +- compatible : should be "fsl,<soc>-fec", "fsl,fec"
>> +- reg : address and length of the register set for the device
>> +- interrupts : should contain fec interrupt
>> +
>> +Example:
>> +
>> +fec@83fec000 {
>> + =A0 =A0 compatible =3D "fsl,imx51-fec", "fsl,fec";
>> + =A0 =A0 reg =3D <0x83fec000 0x4000>;
>> + =A0 =A0 interrupts =3D <87>;
>> +};
>
> How about also adding device_type=3D"network" as required here, so you
> inherit the attributes like "local-mac-address".

local-mac-address should be used regardless.  "device_type" only makes
sense when a platform uses real OpenFirmware with the runtime services
api.  It should not be used with the flat tree.

> I would also suggest adding a call to of_get_mac_address() so you
> can read the address out of the device tree when it is not configured
> in hardware. Today, the driver relies on a module parameter or
> platform_data on hardware with a mac address set.

Yes, of_get_mac_address() is the right thing to do.

g.
