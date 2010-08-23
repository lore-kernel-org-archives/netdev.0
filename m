From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] tc: add meta match on receive hash
Date: Tue, 24 Aug 2010 07:25:19 +0800
Message-ID: <AANLkTik3tnSQOXSQWxX+GqcJpjnEyGuWyZhQ9sbPFYAt@mail.gmail.com>
References: <20100823130803.7736ebfb@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, jamal <hadi@cyberus.ca>,
	Thomas Graf <tgraf@redhat.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:64063 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751045Ab0HWXZk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Aug 2010 19:25:40 -0400
Received: by wyb32 with SMTP id 32so7429713wyb.19
        for <netdev@vger.kernel.org>; Mon, 23 Aug 2010 16:25:39 -0700 (PDT)
In-Reply-To: <20100823130803.7736ebfb@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 24, 2010 at 4:08 AM, Stephen Hemminger
<shemminger@vyatta.com> wrote:
> Trivial extension to existing meta data match rules to allow
> matching on skb receive hash value.
>
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>
> --- a/include/linux/tc_ematch/tc_em_meta.h =A0 =A0 =A02010-08-22 11:2=
8:09.208550912 -0700
> +++ b/include/linux/tc_ematch/tc_em_meta.h =A0 =A0 =A02010-08-22 11:2=
8:20.560321846 -0700
> @@ -79,6 +79,7 @@ enum {
> =A0 =A0 =A0 =A0TCF_META_ID_SK_SENDMSG_OFF,
> =A0 =A0 =A0 =A0TCF_META_ID_SK_WRITE_PENDING,
> =A0 =A0 =A0 =A0TCF_META_ID_VLAN_TAG,
> + =A0 =A0 =A0 TCF_META_ID_RXHASH,
> =A0 =A0 =A0 =A0__TCF_META_ID_MAX
> =A0};
> =A0#define TCF_META_ID_MAX (__TCF_META_ID_MAX - 1)
> --- a/net/sched/em_meta.c =A0 =A0 =A0 2010-08-22 11:23:29.394155391 -=
0700
> +++ b/net/sched/em_meta.c =A0 =A0 =A0 2010-08-22 11:25:16.088029057 -=
0700
> @@ -223,6 +223,11 @@ META_COLLECTOR(int_maclen)
> =A0 =A0 =A0 =A0dst->value =3D skb->mac_len;
> =A0}
>
> +META_COLLECTOR(int_rxhash)
> +{
> + =A0 =A0 =A0 dst->value =3D skb->rxhash;
> +}

How about using skb_get_rxhash instead. It returns the rxhash anyway.

> +
> =A0/*****************************************************************=
*********
> =A0* Netfilter
> =A0******************************************************************=
********/
> @@ -541,6 +546,7 @@ static struct meta_ops __meta_ops[TCF_ME
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0[META_ID(SK_SENDMSG_OFF)] =A0 =A0 =A0 =
=3D META_FUNC(int_sk_sendmsg_off),
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0[META_ID(SK_WRITE_PENDING)] =A0 =A0 =3D=
 META_FUNC(int_sk_write_pend),
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0[META_ID(VLAN_TAG)] =A0 =A0 =A0 =A0 =A0=
 =A0 =3D META_FUNC(int_vlan_tag),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [META_ID(RXHASH)] =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =3D META_FUNC(int_rxhash),
> =A0 =A0 =A0 =A0}
> =A0};
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>



--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
