From: Zhi Yong Wu <zwu.kernel@gmail.com>
Subject: Re: [PATCH] vhost-net: add module alias (v2)
Date: Thu, 12 Jan 2012 10:15:20 +0800
Message-ID: <CAEH94LiF_F51_avA9UWMneo1N1wY0NzJmfohpxdrkAv2WkWT5Q@mail.gmail.com>
References: <20120110205400.6c1cb306@nehalam.linuxnetplumber.net>
	<20120111091653.188b24ab@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alan Cox <device@lanana.org>, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	Kay Sievers <kay.sievers@vrfy.org>, kvm@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:62808 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751974Ab2ALCPZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2012 21:15:25 -0500
In-Reply-To: <20120111091653.188b24ab@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 12, 2012 at 1:16 AM, Stephen Hemminger
<shemminger@vyatta.com> wrote:
> By adding the correct module alias, programs won't have to explicitly
> call modprobe. Vhost-net will always be available if built into the k=
ernel.
> It does require assigning a permanent minor number for depmod to work=
=2E
> Choose one next to TUN since this driver is related to it.
>
> Also, use C99 style initialization.
>
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>
> ---
> v2 - document minor number and make sure to not overlap
>
> =A0Documentation/devices.txt =A0| =A0 =A02 ++
> =A0drivers/vhost/net.c =A0 =A0 =A0 =A0| =A0 =A08 +++++---
> =A0include/linux/miscdevice.h | =A0 =A01 +
> =A03 files changed, 8 insertions(+), 3 deletions(-)
>
> --- a/drivers/vhost/net.c =A0 =A0 =A0 2012-01-10 10:56:58.883179194 -=
0800
> +++ b/drivers/vhost/net.c =A0 =A0 =A0 2012-01-10 19:48:23.650225892 -=
0800
> @@ -856,9 +856,9 @@ static const struct file_operations vhos
> =A0};
>
> =A0static struct miscdevice vhost_net_misc =3D {
> - =A0 =A0 =A0 MISC_DYNAMIC_MINOR,
> - =A0 =A0 =A0 "vhost-net",
> - =A0 =A0 =A0 &vhost_net_fops,
> + =A0 =A0 =A0 .minor =3D VHOST_NET_MINOR,
> + =A0 =A0 =A0 .name =3D "vhost-net",
> + =A0 =A0 =A0 .fops =3D &vhost_net_fops,
> =A0};
>
> =A0static int vhost_net_init(void)
> @@ -879,3 +879,5 @@ MODULE_VERSION("0.0.1");
> =A0MODULE_LICENSE("GPL v2");
> =A0MODULE_AUTHOR("Michael S. Tsirkin");
> =A0MODULE_DESCRIPTION("Host kernel accelerator for virtio net");
> +MODULE_ALIAS_MISCDEV(VHOST_NET_MINOR);
> +MODULE_ALIAS("devname:vhost-net");
> --- a/include/linux/miscdevice.h =A0 =A0 =A0 =A02012-01-10 10:56:59.7=
79189436 -0800
> +++ b/include/linux/miscdevice.h =A0 =A0 =A0 =A02012-01-11 09:13:20.8=
03694316 -0800
> @@ -42,6 +42,7 @@
> =A0#define AUTOFS_MINOR =A0 =A0 =A0 =A0 =A0 235
> =A0#define MAPPER_CTRL_MINOR =A0 =A0 =A0236
> =A0#define LOOP_CTRL_MINOR =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0237
> +#define VHOST_NET_MINOR =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0238
> =A0#define MISC_DYNAMIC_MINOR =A0 =A0 255
>
> =A0struct device;
> --- a/Documentation/devices.txt 2012-01-10 10:56:53.399116518 -0800
> +++ b/Documentation/devices.txt 2012-01-11 09:12:49.251197653 -0800
> @@ -447,6 +447,8 @@ Your cooperation is appreciated.
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0234 =3D /dev/btrfs-control =A0 =A0 =A0=
 =A0Btrfs control device
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0235 =3D /dev/autofs =A0 =A0 =A0 Autofs=
 control device
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0236 =3D /dev/mapper/control =A0 =A0 =A0=
 Device-Mapper control device
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 237 =3D /dev/vhost-net =A0 =A0Host kern=
el accelerator for virtio net
> +
238? The stuff for LOOP_CTRL seems to be missing?

> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0240-254 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 Reserved for local use
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0255 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 Reserved for MISC_DYNAMIC_MINOR
>
>
>
> _______________________________________________
> Virtualization mailing list
> Virtualization@lists.linux-foundation.org
> https://lists.linuxfoundation.org/mailman/listinfo/virtualization



--=20
Regards,

Zhi Yong Wu
