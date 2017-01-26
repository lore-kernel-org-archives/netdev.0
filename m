From: "Amrani, Ram" <Ram.Amrani@cavium.com>
Subject: RE: [PATCH net 1/3] qed: Release CQ resource under lock on failure
Date: Thu, 26 Jan 2017 11:43:24 +0000
Message-ID: <SN1PR07MB2207514E622BF7BED69695F5F8770@SN1PR07MB2207.namprd07.prod.outlook.com>
References: <1485292523-8821-1-git-send-email-Yuval.Mintz@cavium.com>
 <1485292523-8821-2-git-send-email-Yuval.Mintz@cavium.com>
 <20170125072426.GA4973@yuval-lap>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "Kalderon, Michal" <Michal.Kalderon@cavium.com>
To: Yuval Shaia <yuval.shaia@oracle.com>,
        "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0047.outbound.protection.outlook.com ([104.47.42.47]:59456
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750998AbdAZLoz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 26 Jan 2017 06:44:55 -0500
In-Reply-To: <20170125072426.GA4973@yuval-lap>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Minor suggestion.
> Can you consider embedding the lock and unlock inside qed_bmap_release_id=
?
> There are two places where this is bad idea as driver needs to release tw=
o
> IDs but still one is in error flow and second is when destroying QP so fo=
r
> most cases code may look a bit better.
>=20

The bitmap functions are being used by various bitmaps one of which is the =
cid.
The cid code must allocate two consecutive cids. So here the lock is over t=
wo calls
to the bit allocating call.

I am planning to recode the cid to use one bit instead of two, this is furt=
her
down the list.

Thanks for the suggestion,
Ram
