From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC PATCH v2 2/6] net: Add netif_num_vf function
Date: Fri, 18 Dec 2009 17:37:04 +0000
Message-ID: <1261157824.2769.2.camel@achroite.uk.solarflarecom.com>
References: <20091218013329.4510.25937.stgit@localhost.localdomain>
	 <20091218013410.4510.40263.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Mitch Williams <mitch.a.williams@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:44657 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755188AbZLRRhK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2009 12:37:10 -0500
In-Reply-To: <20091218013410.4510.40263.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-12-17 at 17:34 -0800, Jeff Kirsher wrote:
> From: Williams, Mitch A <mitch.a.williams@intel.com>
>=20
> Add a convenience function to determine how many VF devices are assoc=
iated
> with a given PF network interface. If the device is not an SR-IOV phy=
sical
> function device, the function returns 0.
[...]
> +/**
> + *	netif_num_vf - return number of SR-IOV VFs
> + *	@dev: network device
> + *
> + *	Return the number of SR-IOV virtual function devices that are
> + *	associated with this physical function device. Returns 0 if
> + *	device is not a PF device, or if SR-IOV not enabled.
> + */
> +static inline int netif_num_vf(const struct net_device *dev)
> +{
> +	struct pci_dev *pdev;
> +	int retval =3D 0;
> +
> +	if (!dev)
> +		goto out;

=EF=BB=BFWhy should this function allow dev =3D=3D NULL?

> +	if (!dev->dev.parent)
> +		goto out;
> +
> +	if (dev->dev.parent->bus =3D=3D &pci_bus_type) {
> +		pdev =3D to_pci_dev(dev->dev.parent);
> +		retval =3D pci_num_vf(pdev);
> +	}
> +out:
> +	return retval;
[...]

It would be much clearer to write:

	struct pci_dev *pdev;

	if (dev && dev->dev.parent &&
	    dev->dev.parent->bus =3D=3D &pci_bus_type) {
		pdev =3D to_pci_dev(dev->dev.parent);
		return pci_num_vf(pdev);
	} else {
		return 0;
	}

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

