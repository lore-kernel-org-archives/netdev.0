From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH net-next V3] net: ena: Add a driver for Amazon Elastic
 Network Adapters (ENA)
Date: Fri, 15 Jul 2016 08:00:05 +0300
Message-ID: <20160715050005.GD30603@leon.nu>
References: <1468478774-19942-1-git-send-email-netanel@annapurnalabs.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="jL2BoiuKMElzg3CS"
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org, zorik@annapurnalabs.com,
	saeed@annapurnalabs.com, alex@annapurnalabs.com, msw@amazon.com,
	aliguori@amazon.com, benjamin.poirier@gmail.com,
	ben@decadent.org.uk, romieu@fr.zoreil.com, rami.rosen@intel.com,
	antoine.tenart@free-electrons.com
To: Netanel Belgazal <netanel@annapurnalabs.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1468478774-19942-1-git-send-email-netanel@annapurnalabs.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--jL2BoiuKMElzg3CS
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Jul 14, 2016 at 09:46:14AM +0300, Netanel Belgazal wrote:
> This is a driver for the ENA family of networking devices.
>=20
> Signed-off-by: Netanel Belgazal <netanel@annapurnalabs.com>
> ---
>=20
> Notes:

=2E..

>     - Increase driver version to 1.0.2

=2E..

> +static void ena_get_drvinfo(struct net_device *dev,
> +			    struct ethtool_drvinfo *info)
> +{
> +	struct ena_adapter *adapter =3D netdev_priv(dev);
> +
> +	strlcpy(info->driver, DRV_MODULE_NAME, sizeof(info->driver));
> +	strlcpy(info->version, DRV_MODULE_VERSION, sizeof(info->version));

Does module version give anything valuable in real life usage?
Do you plan to bump version after every patch?

Hint, NO.

> +	strlcpy(info->bus_info, pci_name(adapter->pdev),
> +		sizeof(info->bus_info));
> +}
> +
> +

=2E..

> +
> +static char version[] =3D
> +		DEVICE_NAME " v"
> +		DRV_MODULE_VERSION " (" DRV_MODULE_RELDATE ")\n";
> +
> +MODULE_AUTHOR("Amazon.com, Inc. or its affiliates");
> +MODULE_DESCRIPTION(DEVICE_NAME);
> +MODULE_LICENSE("GPL");
> +MODULE_VERSION(DRV_MODULE_VERSION);
> +
> +/* Time in jiffies before concluding the transmitter is hung. */
> +#define TX_TIMEOUT  (5 * HZ)
> +
> +#define ENA_NAPI_BUDGET 64
> +
> +#define DEFAULT_MSG_ENABLE (NETIF_MSG_DRV | NETIF_MSG_PROBE | NETIF_MSG_=
IFUP | \
> +		NETIF_MSG_TX_DONE | NETIF_MSG_TX_ERR | NETIF_MSG_RX_ERR)
> +static int debug =3D -1;
> +module_param(debug, int, 0);
> +MODULE_PARM_DESC(debug, "Debug level (0=3Dnone,...,16=3Dall)");

What is it?

> +
> +static int push_mode;
> +module_param(push_mode, int, 0);
> +MODULE_PARM_DESC(push_mode, "Descriptor / header push mode (0=3Dautomati=
c,1=3Ddisable,3=3Denable)\n"
> +		 "\t\t\t  0 - Automatically choose according to device capability (def=
ault)\n"
> +		 "\t\t\t  1 - Don't push anything to device memory\n"
> +		 "\t\t\t  3 - Push descriptors and header buffer to device memory");
> +
> +static int enable_wd =3D 1;
> +module_param(enable_wd, int, 0);
> +MODULE_PARM_DESC(enable_wd, "Enable keepalive watchdog (0=3Ddisable,1=3D=
enable,default=3D1)");
> +
> +static int enable_missing_tx_detection =3D 1;
> +module_param(enable_missing_tx_detection, int, 0);
> +MODULE_PARM_DESC(enable_missing_tx_detection, "Enable missing Tx complet=
ions. (default=3D1)");
> +
> +static int numa_node_override_array[NR_CPUS] =3D {[0 ... (NR_CPUS - 1)] =
=3D NUMA_NO_NODE };
> +module_param_array(numa_node_override_array, int, NULL, 0);
> +MODULE_PARM_DESC(numa_node_override_array, "Numa node override map\n");
> +
> +static int numa_node_override;
> +module_param(numa_node_override, int, 0);
> +MODULE_PARM_DESC(numa_node_override, "Enable/Disable numa node override =
(0=3Ddisable)\n");

As fas as I remember, new drivers are not supposed to add module
parameters.

=2E..

> +
> +#define DRV_MODULE_VER_MAJOR	1
> +#define DRV_MODULE_VER_MINOR	0
> +#define DRV_MODULE_VER_SUBMINOR 1
> +
> +#define DRV_MODULE_NAME		"ena"
> +#ifndef DRV_MODULE_VERSION
> +#define DRV_MODULE_VERSION \
> +	__stringify(DRV_MODULE_VER_MAJOR) "."	\
> +	__stringify(DRV_MODULE_VER_MINOR) "."	\
> +	__stringify(DRV_MODULE_VER_SUBMINOR)
> +#endif
> +#define DRV_MODULE_RELDATE      "22-JUNE-2016"

Please remove it, driver version is useless in real life kernel usage.


--jL2BoiuKMElzg3CS
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJXiG3VAAoJEORje4g2cliniewP/39ayTxE1HGId0+LFa1PRFZ4
IUwyRiwQOeMJlrL6fPADGMLgTeofJvwtX7MbSK5dGmo9QER59ZFJKF8d8jS/wY57
jBE19iumJCNq1kFu2cbrBsUDBj9tmq7oFG1PPCHUqLOvz31IDxThs/4la9Co4UMe
upf5ucffHSeYzhERP2uxsxp8l9YGLoW2I5Ov97yj/osE98pk67DCiyKRuEIdp1jr
/7P2zYSdpsoOl4Hj++oYZd8XG4br5K3qvvr2FiKco4K0YpCTxLi9tqcErT8/ibDX
I73J7rDJl5aeOjWt+tq09h/xWAmx01tgRKN+SXhvZxKW2w/dEgoGe0/kr9ccCPx+
8r5oZI9GIzmCd7GL6K7hi1RJDyO1ANncfUyJBOm+ZucgsVhueqCHp1sLidSJ7gBU
IRJEVDOKg1ckur0QYQsw4PwUvVvcJqunkF+lHHK5sz222/S1+Vms2JPZhRtmuglb
H6z1YMPV29TEh5Vw6OMKaxm85W6j5TFZrSPd1WLt7dEYQqlxJYSU24PBQM+PKgnB
0ZpTgjkGEHzevWvxS77Kxd4nOw6Fx7lnPjQHmxlKWcJR/7mhd1pZq/bnUDihW/Q/
QtnCNC2PND+Cw/CELIqfAc0T6o06SbDooJ1SmRFRylGXSU+YHINjiXxrLfav1Qt/
ZBRQnVo7JtolTw8fYENT
=yk+W
-----END PGP SIGNATURE-----

--jL2BoiuKMElzg3CS--
