From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH] Use dev_port for the ID of a network device.
Date: Tue, 01 Jul 2014 08:45:56 +0200
Message-ID: <87egy54lwb.fsf@nemi.mork.no>
References: <1404160596-25859-1-git-send-email-cascardo@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: systemd-devel@lists.freedesktop.org, netdev@vger.kernel.org
To: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:44725 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750869AbaGAGqQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jul 2014 02:46:16 -0400
In-Reply-To: <1404160596-25859-1-git-send-email-cascardo@linux.vnet.ibm.com>
	(Thadeu Lima de Souza Cascardo's message of "Mon, 30 Jun 2014 17:36:36
	-0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com> writes:

> diff --git a/src/udev/udev-builtin-net_id.c b/src/udev/udev-builtin-n=
et_id.c
> index c80c30a..6de9c98 100644
> --- a/src/udev/udev-builtin-net_id.c
> +++ b/src/udev/udev-builtin-net_id.c
> @@ -186,9 +186,14 @@ static int dev_pci_slot(struct udev_device *dev,=
 struct netnames *names) {
>                  return -ENOENT;
> =20
>          /* kernel provided multi-device index */
> -        attr =3D udev_device_get_sysattr_value(dev, "dev_id");
> -        if (attr)
> +        attr =3D udev_device_get_sysattr_value(dev, "dev_port");
> +        if (attr) {
>                  dev_id =3D strtol(attr, NULL, 16);
> +        } else {
> +                attr =3D udev_device_get_sysattr_value(dev, "dev_id"=
);
> +                if (attr)
> +                        dev_id =3D strtol(attr, NULL, 16);
> +        }
> =20
>          /* compose a name based on the raw kernel's PCI bus, slot nu=
mbers */
>          s =3D names->pci_path;

Note that the base of the new attribute is 10, not 16:

bjorn@nemi:/usr/local/src/git/linux$ git grep dev_port net/core/
net/core/net-sysfs.c:NETDEVICE_SHOW_RO(dev_port, fmt_dec);
net/core/net-sysfs.c:   &dev_attr_dev_port.attr,
bjorn@nemi:/usr/local/src/git/linux$ git grep dev_id net/core/
net/core/net-sysfs.c:NETDEVICE_SHOW_RO(dev_id, fmt_hex);
net/core/net-sysfs.c:   &dev_attr_dev_id.attr,



Bj=C3=B8rn
