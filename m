From: Kalle Valo <kvalo@qca.qualcomm.com>
Subject: Re: [PATCH net-next] ath10k: wmi: Convert use of 6 to ETH_ALEN
Date: Thu, 3 Oct 2013 07:54:39 +0300
Message-ID: <87bo37ymwg.fsf@kamboji.qca.qualcomm.com>
References: <1380679480.2081.24.camel@joe-AO722>
	<87k3hw469z.fsf@kamboji.qca.qualcomm.com>
	<1380696054.2081.35.camel@joe-AO722>
	<CAB=NE6V3b4+B06hzPjhww52wp1FHho3329cP25=5Cy833bysvg@mail.gmail.com>
	<1380736969.2081.72.camel@joe-AO722>
	<alpine.DEB.2.02.1310030034030.2162@localhost6.localdomain6>
	<1380758954.2081.79.camel@joe-AO722>
	<1380760114.2081.81.camel@joe-AO722>
	<1380771110.2081.89.camel@joe-AO722>
	<1380771551.2081.93.camel@joe-AO722>
	<1380773924.19002.131.camel@edumazet-glaptop.roam.corp.google.com>
	<87fvsjynuk.fsf@kamboji.qca.qualcomm.com>
	<1380775478.19002.139.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Joe Perches <joe@perches.com>, Julia Lawall <julia.lawall@lip6.fr>,
	"Luis R. Rodriguez" <mcgrof@do-not-panic.com>,
	netdev <netdev@vger.kernel.org>, <ath10k@lists.infradead.org>,
	"John W. Linville" <linville@tuxdriver.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sabertooth01.qualcomm.com ([65.197.215.72]:20638 "EHLO
	sabertooth01.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755030Ab3JCEyq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Oct 2013 00:54:46 -0400
In-Reply-To: <1380775478.19002.139.camel@edumazet-glaptop.roam.corp.google.com>
	(Eric Dumazet's message of "Wed, 2 Oct 2013 21:44:38 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:

> On Thu, 2013-10-03 at 07:34 +0300, Kalle Valo wrote:
>
>> Do you mean '6' or the union? The 6 can replaced with ETH_ALEN AFAICS.
>> But the union is needed for aligning the packets as firmware expects
>> them.
>
> I mean the 6, of course, since Joe seems to actively track them, as if
> ETH_ALEN could change eventually, you never know.
>
> I am worrying this will take another hundred patches ...

Ah, ok.

> Regarding this union, the __packed attributes seem overkill, no ???

Yeah, they do. This should be enough, right?

struct wmi_mac_addr {
	union {
		u8 addr[6];
		struct {
			u32 word0;
			u32 word1;
		};
	};
} __packed;

-- 
Kalle Valo
