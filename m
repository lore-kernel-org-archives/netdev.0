From: "Jorgen S. Hansen" <jhansen@vmware.com>
Subject: Re: [PATCH][V2] VSOCK: remove unnecessary ternary operator on return
 value
Date: Thu, 30 Mar 2017 13:18:10 +0000
Message-ID: <3658D20B-EBF9-48A2-95A7-026D36F18AF8@vmware.com>
References: <20170329153355.17525-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "David S . Miller" <davem@davemloft.net>,
        "Michael S . Tsirkin" <mst@redhat.com>,
        Adit Ranadive <aditr@vmware.com>,
        George Zhang <georgezhang@vmware.com>,
        Stefan Hajnoczi <stefanha@redhat.com>,
        Julia Lawall <julia.lawall@lip6.fr>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Colin King <colin.king@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0068.outbound.protection.outlook.com ([104.47.37.68]:48304
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S933160AbdC3NSP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 30 Mar 2017 09:18:15 -0400
In-Reply-To: <20170329153355.17525-1-colin.king@canonical.com>
Content-Language: en-US
Content-ID: <BEFC289403EED843BB71F683E1EAD261@namprd05.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Mar 29, 2017, at 5:33 PM, Colin King <colin.king@canonical.com> wrote:
>=20
> From: Colin Ian King <colin.king@canonical.com>
>=20
> Rather than assign the positive errno values to ret and then
> checking if it is positive and flip the sign, just return the
> errno value.
>=20
> Detected by CoverityScan, CID#986649 ("Logically Dead Code")
>=20
> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> ---
> net/vmw_vsock/vmci_transport.c | 22 +++++++---------------
> 1 file changed, 7 insertions(+), 15 deletions(-)
>=20
> diff --git a/net/vmw_vsock/vmci_transport.c b/net/vmw_vsock/vmci_transpor=
t.c
> index 4be4fbbc0b50..10ae7823a19d 100644
> --- a/net/vmw_vsock/vmci_transport.c
> +++ b/net/vmw_vsock/vmci_transport.c
> @@ -96,31 +96,23 @@ static int PROTOCOL_OVERRIDE =3D -1;
>=20
> static s32 vmci_transport_error_to_vsock_error(s32 vmci_error)
> {
> -	int err;
> -
> 	switch (vmci_error) {
> 	case VMCI_ERROR_NO_MEM:
> -		err =3D ENOMEM;
> -		break;
> +		return -ENOMEM;
> 	case VMCI_ERROR_DUPLICATE_ENTRY:
> 	case VMCI_ERROR_ALREADY_EXISTS:
> -		err =3D EADDRINUSE;
> -		break;
> +		return -EADDRINUSE;
> 	case VMCI_ERROR_NO_ACCESS:
> -		err =3D EPERM;
> -		break;
> +		return -EPERM;
> 	case VMCI_ERROR_NO_RESOURCES:
> -		err =3D ENOBUFS;
> -		break;
> +		return -ENOBUFS;
> 	case VMCI_ERROR_INVALID_RESOURCE:
> -		err =3D EHOSTUNREACH;
> -		break;
> +		return -EHOSTUNREACH;
> 	case VMCI_ERROR_INVALID_ARGS:
> 	default:
> -		err =3D EINVAL;
> +		break;
> 	}
> -
> -	return err > 0 ? -err : err;
> +	return -EINVAL;
> }
>=20
> static u32 vmci_transport_peer_rid(u32 peer_cid)
> --=20
> 2.11.0
>=20

Reviewed-by: Jorgen Hansen <jhansen@vmware.com>
