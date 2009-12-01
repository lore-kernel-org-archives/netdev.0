From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH 00/10] Remove skb_dma_map/unmap calls
Date: Tue, 01 Dec 2009 05:34:47 +0100
Message-ID: <4B149CE7.4020001@gmail.com>
References: <20091125011111.32704.3009.stgit@gitlad.jf.intel.com>	<20091129.234037.232627669.davem@davemloft.net>	<80769D7B14936844A23C0C43D9FBCF0F12C7400AD3@orsmsx501.amr.corp.intel.com> <20091130.201625.193689129.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: alexander.h.duyck@intel.com, mcarlson@broadcom.com,
	mchan@broadcom.com, sathyap@serverengines.com,
	subbus@serverengines.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:48019 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752397AbZLAEew (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 23:34:52 -0500
In-Reply-To: <20091130.201625.193689129.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: "Duyck, Alexander H" <alexander.h.duyck@intel.com>
> Date: Mon, 30 Nov 2009 17:03:25 -0800
>=20
>> David Miller wrote:
>>> These changes look good, but at least one of them does not apply
>>> to current net-2.6
>>>
>>> Can you respin this against current sources?
>>>
>>> Thanks a lot for doing this work Alexander.
>> Due to the fact that nobody else had reported the issue and it
>> existed in previous kernel versions I figured it would be easier to
>> just drop it into net-next-2.6.
>>
>> If you want I can change the patches to net-2.6 though if that is
>> what you would prefer.
>=20
> Ok, net-next-2.6 is fine with me too.

I am not sure if I already mentioned these patches speedup
TX completion path, since we avoid a cache line miss, if
driver caches nr_frags/mapping in its tx descriptor (like bnx2)

(no need to access to skb_shinfo(skb)->dma_head & ->nr_frags)

(This is not an argument vs ns-next-2.6, or net-2.6, just a note
to say that these patches are welcomed performance wise)
