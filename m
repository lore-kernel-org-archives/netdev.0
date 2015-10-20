From: Jarno Rajahalme <jrajahalme@nicira.com>
Subject: Re: [RFC PATCH 1/5] netfilter: Remove IP_CT_NEW_REPLY definition.
Date: Tue, 20 Oct 2015 15:28:18 -0700
Message-ID: <1C66DF30-22EB-49A4-A561-4EF7E2B84A74@nicira.com>
References: <1445379629-112880-1-git-send-email-jrajahalme@nicira.com>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dev@openvswitch.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:36191 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753429AbbJTW2U convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2015 18:28:20 -0400
Received: by pacfv9 with SMTP id fv9so34798439pac.3
        for <netdev@vger.kernel.org>; Tue, 20 Oct 2015 15:28:19 -0700 (PDT)
In-Reply-To: <1445379629-112880-1-git-send-email-jrajahalme@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I missed the =E2=80=9Cnet-next=E2=80=9D label from the title, sorry for=
 that.

  Jarno

> On Oct 20, 2015, at 3:20 PM, Jarno Rajahalme <jrajahalme@nicira.com> =
wrote:
>=20
> Remove the definition of IP_CT_NEW_REPLY as it does not make sense.
> This allows the definition of IP_CT_NUMBER to be simplified as well.
>=20
> Signed-off-by: Jarno Rajahalme <jrajahalme@nicira.com>
> ---
> include/uapi/linux/netfilter/nf_conntrack_common.h | 7 ++++---
> net/openvswitch/conntrack.c                        | 2 --
> 2 files changed, 4 insertions(+), 5 deletions(-)
>=20
> diff --git a/include/uapi/linux/netfilter/nf_conntrack_common.h b/inc=
lude/uapi/linux/netfilter/nf_conntrack_common.h
> index 319f471..e0aebc8 100644
> --- a/include/uapi/linux/netfilter/nf_conntrack_common.h
> +++ b/include/uapi/linux/netfilter/nf_conntrack_common.h
> @@ -20,9 +20,10 @@ enum ip_conntrack_info {
>=20
> 	IP_CT_ESTABLISHED_REPLY =3D IP_CT_ESTABLISHED + IP_CT_IS_REPLY,
> 	IP_CT_RELATED_REPLY =3D IP_CT_RELATED + IP_CT_IS_REPLY,
> -	IP_CT_NEW_REPLY =3D IP_CT_NEW + IP_CT_IS_REPLY,=09
> -	/* Number of distinct IP_CT types (no NEW in reply dirn). */
> -	IP_CT_NUMBER =3D IP_CT_IS_REPLY * 2 - 1
> +	/* No IP_CT_NEW_REPLY */
> +
> +	/* Number of distinct IP_CT types. */
> +	IP_CT_NUMBER
> };
>=20
> #define NF_CT_STATE_INVALID_BIT			(1 << 0)
> diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.=
c
> index ad61426..097ace4 100644
> --- a/net/openvswitch/conntrack.c
> +++ b/net/openvswitch/conntrack.c
> @@ -73,7 +73,6 @@ static u8 ovs_ct_get_state(enum ip_conntrack_info c=
tinfo)
> 	switch (ctinfo) {
> 	case IP_CT_ESTABLISHED_REPLY:
> 	case IP_CT_RELATED_REPLY:
> -	case IP_CT_NEW_REPLY:
> 		ct_state |=3D OVS_CS_F_REPLY_DIR;
> 		break;
> 	default:
> @@ -90,7 +89,6 @@ static u8 ovs_ct_get_state(enum ip_conntrack_info c=
tinfo)
> 		ct_state |=3D OVS_CS_F_RELATED;
> 		break;
> 	case IP_CT_NEW:
> -	case IP_CT_NEW_REPLY:
> 		ct_state |=3D OVS_CS_F_NEW;
> 		break;
> 	default:
> --=20
> 2.1.4
>=20
