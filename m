From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: Nested function in drivers/of/of_mdio.c
Date: Wed, 7 Oct 2009 10:11:14 -0600
Message-ID: <fa686aa40910070911x769d7d41u908fbcf6b0980962@mail.gmail.com>
References: <200910071715.57249.jezz@sysmic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: netdev <netdev@vger.kernel.org>, linuxppc <linuxppc-dev@lists.ozlabs.org>,
	Andy Fleming <afleming@freescale.com>,
	"David S. Miller" <davem@davemloft.net>
To: =?ISO-8859-1?Q?J=E9r=F4me_Pouiller?= <jezz@sysmic.org>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <200910071715.57249.jezz@sysmic.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 7, 2009 at 9:15 AM, J=E9r=F4me Pouiller <jezz@sysmic.org> wrote:
> Dear,
>
> I have a problem with commit 8bc487d150b939e69830c39322df4ee486efe381
> in file drivers/of/of_mdio.c in function of_phy_find_device.
>
> As you see, this function define match() as a nested function. My
> compiler (powerpc-e500-linux-gnu-gcc-3.4.1) raise an error during link
> due to this nested definition:
> =A0drivers/built-in.o(.text+0x5e2a4): In function `of_phy_find_device': /=
home/jezz/linux-next/drivers/of/of_mdio.c:107:
> undefined reference to `__trampoline_setup'
>
> I am sure I could solve problem by rebuilding my toolchain.
> Nevertheless, I think nested function definition is not perfectly
> supported by all compilers. Also, I suggest to place function match()
> outside of scope of of_phy_find_device as in following patch.

I'm okay with that, but if you're moving code out of the file scope,
then please rename the function to of_phy_match() to avoid global
namespace conflicts.

g.

>
> diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
> index bacaa53..c7b2e26 100644
> --- a/drivers/of/of_mdio.c
> +++ b/drivers/of/of_mdio.c
> @@ -97,6 +97,10 @@ int of_mdiobus_register(struct mii_bus *mdio, struct d=
evice_node *np)
> =A0}
> =A0EXPORT_SYMBOL(of_mdiobus_register);
>
> +static int match(struct device *dev, void *phy_np)
> +{
> + =A0 =A0 =A0 return dev_archdata_get_node(&dev->archdata) =3D=3D phy_np;
> +}
> =A0/**
> =A0* of_phy_find_device - Give a PHY node, find the phy_device
> =A0* @phy_np: Pointer to the phy's device tree node
> @@ -106,11 +110,6 @@ EXPORT_SYMBOL(of_mdiobus_register);
> =A0struct phy_device *of_phy_find_device(struct device_node *phy_np)
> =A0{
> =A0 =A0 =A0 =A0struct device *d;
> - =A0 =A0 =A0 int match(struct device *dev, void *phy_np)
> - =A0 =A0 =A0 {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return dev_archdata_get_node(&dev->archdata=
) =3D=3D phy_np;
> - =A0 =A0 =A0 }
> -
> =A0 =A0 =A0 =A0if (!phy_np)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return NULL;
>
>
> What do you think about it?
>
> Best regards,
>
> --
> J=E9r=F4me Pouiller (jezz AT sysmic DOT org)
>



-- =

Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
