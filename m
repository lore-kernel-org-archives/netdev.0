From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: igb driver triggers BUILD_BUG_ON on s390
Date: Mon, 11 Mar 2013 08:47:12 -0700
Message-ID: <513DFC80.5000105@intel.com>
References: <20130309100004.GA3584@osiris>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:61013 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751319Ab3CKPrP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Mar 2013 11:47:15 -0400
In-Reply-To: <20130309100004.GA3584@osiris>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/09/2013 02:00 AM, Heiko Carstens wrote:
> git commit 74e238ead "igb: Support using build_skb in the case that
> jumbo frames are disabled" added a BUILD_BUG_ON() to the igb drivers
> which triggers on s390:
>
> drivers/net/ethernet/intel/igb/igb_main.c:6231:2:
> error: call to =91__compiletime_assert_6235=92 declared with attribut=
e error:
>   BUILD_BUG_ON failed: SKB_WITH_OVERHEAD(IGB_RX_BUFSZ) <
>     (NET_SKB_PAD + NET_IP_ALIGN + IGB_TS_HDR_LEN + ETH_FRAME_LEN + ET=
H_FCS_LEN)
>
> This happens mainly because s390 has an unusual large L1_CACHE_BYTES =
aka
> SMP_CACHE_BYTES define with 256 Bytes.
>
> The BUILD_BUG_ON(..) translates to (taken from .i file):
>
> __cond =3D !(!(((2048) - (((sizeof(struct skb_shared_info)) + (256 - =
1)) & ~(256 - 1))) < (32 + 2 + 16 + 1514 + 4)));
>
> With sizeof(struct skb_shared_info) =3D=3D 320 we end up with
>
> BUILD_BUG_ON((2048 - 512 =3D 1536) < 1568)
>
> One possible solution would be to simply disable the driver on s390.
> Any opinions?
>

A fix for this has already been submitted. As it turns out the
BUILD_BUG_ON is mostly redundant anyway since we used a similar
calculation to determine if we were going to enable the use of build_sk=
b
per ring.

Thanks,

Alex
