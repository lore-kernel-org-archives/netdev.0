From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: Re: [PATCH net-next 6/7] bnxt_en: Implement xmit_more.
Date: Tue, 30 May 2017 03:28:24 +0000
Message-ID: <BLUPR0701MB20040DED85E53FEFE75C591E8DF00@BLUPR0701MB2004.namprd07.prod.outlook.com>
References: <1496099170-701-1-git-send-email-michael.chan@broadcom.com>,<1496099170-701-7-git-send-email-michael.chan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Michael Chan <michael.chan@broadcom.com>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0046.outbound.protection.outlook.com ([104.47.40.46]:7104
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750733AbdE3D22 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 29 May 2017 23:28:28 -0400
In-Reply-To: <1496099170-701-7-git-send-email-michael.chan@broadcom.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> -=A0=A0=A0=A0=A0=A0 bnxt_db_write(bp, txr->tx_doorbell, DB_KEY_TX | prod)=
;
> +=A0=A0=A0=A0=A0=A0 if (!skb->xmit_more)
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 bnxt_db_write(bp, txr->tx_doo=
rbell, DB_KEY_TX | prod);

DQL can prevent you from getting the xmit_more marked SKB,
so you should probably also check for netif_xmit_stopped().=
