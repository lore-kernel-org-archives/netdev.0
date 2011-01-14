From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: Kernel 2.6.37-git10 build failure: cassini.c
Date: Fri, 14 Jan 2011 14:01:17 -0700
Message-ID: <AANLkTi=dzWv5DLs8iMm4K8pdneo9aex68wzvwuhSHcG=@mail.gmail.com>
References: <AANLkTin61iqrD0Jbax+cvQ1wxD8b=c4KJv7pBSvU7kbv@mail.gmail.com> <20110114.124116.197952526.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: anca.emanuel@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, eric.dumazet@gmail.com, joe@perches.com,
	siccegge@cs.fau.de, jpirko@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110114.124116.197952526.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2011/1/14 David Miller <davem@davemloft.net>:
> From: Anca Emanuel <anca.emanuel@gmail.com>
> Date: Fri, 14 Jan 2011 10:09:43 +0200
>
>> drivers/net/cassini.c: In function =91cas_get_vpd_info=92:
>> drivers/net/cassini.c:3358: error: implicit declaration of function
>> =91of_get_property=92
>> drivers/net/cassini.c:3358: warning: assignment makes pointer from
>> integer without a cast
>> drivers/net/cassini.c: In function =91cas_init_one=92:
>> drivers/net/cassini.c:5035: error: implicit declaration of function
>> =91pci_device_to_OF_node=92
>> drivers/net/cassini.c:5035: warning: assignment makes pointer from
>> integer without a cast
>> make[3]: *** [drivers/net/cassini.o] Error 1
>> make[2]: *** [drivers/net] Error 2
>
> This is the fix I'll be using:
>
> --------------------
> cassini: Fix build bustage on x86.
>
> Unfortunately, not all CONFIG_OF platforms provide
> pci_device_to_OF_node().
>
> Change the test to CONFIG_SPARC for now to deal with
> the build regressions.
>
> Signed-off-by: David S. Miller <davem@davemloft.net>

Acked-by: Grant Likely <grant.likely@secretlab.ca>

pci_device_to_OF_node() will probably become available for all
CONFIG_OF users in 2.6.39.  In the meantime, I agree with this
solution.

g.

> ---
> =A0drivers/net/cassini.c | =A0 =A06 +++---
> =A01 files changed, 3 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/net/cassini.c b/drivers/net/cassini.c
> index 7206ab2..3437613 100644
> --- a/drivers/net/cassini.c
> +++ b/drivers/net/cassini.c
> @@ -3203,7 +3203,7 @@ static int cas_get_vpd_info(struct cas *cp, uns=
igned char *dev_addr,
> =A0 =A0 =A0 =A0int phy_type =3D CAS_PHY_MII_MDIO0; /* default phy typ=
e */
> =A0 =A0 =A0 =A0int mac_off =A0=3D 0;
>
> -#if defined(CONFIG_OF)
> +#if defined(CONFIG_SPARC)
> =A0 =A0 =A0 =A0const unsigned char *addr;
> =A0#endif
>
> @@ -3354,7 +3354,7 @@ use_random_mac_addr:
> =A0 =A0 =A0 =A0if (found & VPD_FOUND_MAC)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto done;
>
> -#if defined(CONFIG_OF)
> +#if defined(CONFIG_SPARC)
> =A0 =A0 =A0 =A0addr =3D of_get_property(cp->of_node, "local-mac-addre=
ss", NULL);
> =A0 =A0 =A0 =A0if (addr !=3D NULL) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0memcpy(dev_addr, addr, 6);
> @@ -5031,7 +5031,7 @@ static int __devinit cas_init_one(struct pci_de=
v *pdev,
> =A0 =A0 =A0 =A0cp->msg_enable =3D (cassini_debug < 0) ? CAS_DEF_MSG_E=
NABLE :
> =A0 =A0 =A0 =A0 =A0cassini_debug;
>
> -#if defined(CONFIG_OF)
> +#if defined(CONFIG_SPARC)
> =A0 =A0 =A0 =A0cp->of_node =3D pci_device_to_OF_node(pdev);
> =A0#endif
>
> --
> 1.7.3.4
>
>



--=20
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
