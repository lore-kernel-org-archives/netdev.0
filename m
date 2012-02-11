From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 02/16] e100: Support RXFCS feature flag.
Date: Sat, 11 Feb 2012 18:07:40 +0100
Message-ID: <1328980060.5661.36.camel@edumazet-laptop>
References: <1328922274-23993-1-git-send-email-greearb@candelatech.com>
	 <1328922274-23993-3-git-send-email-greearb@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:57475 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753474Ab2BKRHs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Feb 2012 12:07:48 -0500
Received: by werb13 with SMTP id b13so2673217wer.19
        for <netdev@vger.kernel.org>; Sat, 11 Feb 2012 09:07:46 -0800 (PST)
In-Reply-To: <1328922274-23993-3-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 10 f=C3=A9vrier 2012 =C3=A0 17:04 -0800, greearb@candelatec=
h.com a
=C3=A9crit :
> From: Ben Greear <greearb@candelatech.com>
>=20
> This allows e100 to be configured to append the
> Ethernet FCS to the skb.
>=20
> Useful for sniffing networks.
>=20
> Signed-off-by: Ben Greear <greearb@candelatech.com>
> ---

Did you try this patch with 8021Q frames ?

You must change=20

#define RFD_BUF_LEN (sizeof(struct rfd) + VLAN_ETH_FRAME_LEN)

to :

#define RFD_BUF_LEN (sizeof(struct rfd) + VLAN_ETH_FRAME_LEN + ETH_FCS_=
LEN)

And also on various spots where VLAN_ETH_FRAME_LEN is used in this
driver...

nic->blank_rfd.size =3D cpu_to_le16(VLAN_ETH_FRAME_LEN);
