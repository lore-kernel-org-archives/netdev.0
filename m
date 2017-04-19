From: KY Srinivasan <kys@microsoft.com>
Subject: RE: [PATCH 1/1] netvsc: Deal with rescinded channels correctly
Date: Wed, 19 Apr 2017 20:52:14 +0000
Message-ID: <CY4PR03MB24876F43572194D377DAB713A0180@CY4PR03MB2487.namprd03.prod.outlook.com>
References: <1492634959-28942-1-git-send-email-kys@exchange.microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
To: KY Srinivasan <kys@microsoft.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
        "olaf@aepfle.de" <olaf@aepfle.de>,
        "apw@canonical.com" <apw@canonical.com>,
        "jasowang@redhat.com" <jasowang@redhat.com>,
        "leann.ogasawara@canonical.comi" <leann.ogasawara@canonical.comi>,
        "marcelo.cerri@canonical.com" <marcelo.cerri@canonical.com>,
        Stephen Hemminger <sthemmin@microsoft.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1492634959-28942-1-git-send-email-kys@exchange.microsoft.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: kys@exchange.microsoft.com [mailto:kys@exchange.microsoft.com]
> Sent: Wednesday, April 19, 2017 1:49 PM
> To: davem@davemloft.net; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org; devel@linuxdriverproject.org; olaf@aepfle.de;
> apw@canonical.com; jasowang@redhat.com;
> leann.ogasawara@canonical.comi; marcelo.cerri@canonical.com; Stephen
> Hemminger <sthemmin@microsoft.com>
> Cc: KY Srinivasan <kys@microsoft.com>
> Subject: [PATCH 1/1] netvsc: Deal with rescinded channels correctly
>=20
> [This sender failed our fraud detection checks and may not be who they
> appear to be. Learn about spoofing at http://aka.ms/LearnAboutSpoofing]
>=20
> From: K. Y. Srinivasan <kys@microsoft.com>
>=20
> We will not be able to send packets over a channel that has been
> rescinded. Make necessary adjustments so we can properly cleanup
> even when the channel is rescinded. This issue can be trigerred
> in the NIC hot-remove path.
>=20
> Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>

Dave,

Please drop this path; I will resend.

K. Y
> ---
>  drivers/net/hyperv/netvsc.c |   16 ++++++++++++++++
>  1 files changed, 16 insertions(+), 0 deletions(-)
>=20
> diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
> index 7ab06b3..b5b10fc 100644
> --- a/drivers/net/hyperv/netvsc.c
> +++ b/drivers/net/hyperv/netvsc.c
> @@ -135,6 +135,13 @@ static void netvsc_destroy_buf(struct hv_device
> *device)
>                                        sizeof(struct nvsp_message),
>                                        (unsigned long)revoke_packet,
>                                        VM_PKT_DATA_INBAND, 0);
> +               /* If the failure is because the channel is rescinded;
> +                * ignore the failure since we cannot send on a rescinded
> +                * channel. This would allow us to properly cleanup
> +                * even when the channel is rescinded.
> +                */
> +               if (device->channel->rescind)
> +                       ret =3D 0;
>                 /*
>                  * If we failed here, we might as well return and
>                  * have a leak rather than continue and a bugchk
> @@ -195,6 +202,15 @@ static void netvsc_destroy_buf(struct hv_device
> *device)
>                                        sizeof(struct nvsp_message),
>                                        (unsigned long)revoke_packet,
>                                        VM_PKT_DATA_INBAND, 0);
> +
> +               /* If the failure is because the channel is rescinded;
> +                * ignore the failure since we cannot send on a rescinded
> +                * channel. This would allow us to properly cleanup
> +                * even when the channel is rescinded.
> +                */
> +               if (device->channel->rescind)
> +                       ret =3D 0;
> +
>                 /* If we failed here, we might as well return and
>                  * have a leak rather than continue and a bugchk
>                  */
> --
> 1.7.1
