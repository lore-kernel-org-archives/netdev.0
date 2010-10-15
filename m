From: Jesse Gross <jesse@nicira.com>
Subject: Re: [RFC PATCH 3/7] bnx2: Update bnx2 to use new vlan accleration.
Date: Thu, 14 Oct 2010 18:36:21 -0700
Message-ID: <AANLkTikBVhCkyX2JVmgd2FXHs_OnV=sy5P9dh3tL8odB@mail.gmail.com>
References: <1287000177-7126-1-git-send-email-jesse@nicira.com>
	<1287000177-7126-4-git-send-email-jesse@nicira.com>
	<1287096960.14523.31.camel@nseg_linux_HP1.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:41423 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753506Ab0JOBgW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Oct 2010 21:36:22 -0400
Received: by iwn35 with SMTP id 35so281358iwn.19
        for <netdev@vger.kernel.org>; Thu, 14 Oct 2010 18:36:21 -0700 (PDT)
In-Reply-To: <1287096960.14523.31.camel@nseg_linux_HP1.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 14, 2010 at 3:56 PM, Michael Chan <mchan@broadcom.com> wrot=
e:
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if ((status & L2_FHDR_STATUS_L2_VLAN_TAG=
) &&
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 !(bp->rx_mode & BNX2_EMAC_RX_MODE_=
KEEP_VLAN_TAG)) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vtag =3D rx_hdr->l2_fhdr_v=
lan_tag;
>> -#ifdef BCM_VLAN
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (bp->vlgrp)
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 hw_vlan =3D=
 1;
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
>> -#endif
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 {
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct vla=
n_ethhdr *ve =3D (struct vlan_ethhdr *)
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 __skb_push(skb, 4);
>> -
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 memmove(ve=
, skb->data + 4, ETH_ALEN * 2);
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ve->h_vlan=
_proto =3D htons(ETH_P_8021Q);
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ve->h_vlan=
_TCI =3D htons(vtag);
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 len +=3D 4=
;
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> - =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 !(bp->rx_mode & BNX2_EMAC_RX_MODE_=
KEEP_VLAN_TAG))
>
> This check for the rx_mode bit is no longer necessary if we always
> configure the chip to strip out the vlan tag.

Thanks, I've dropped it from my local tree.  I may add support for
ethtool to disable vlan stripping in the future, so I might have to
add it back.
