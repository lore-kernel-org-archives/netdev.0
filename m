From: =?UTF-8?B?RnJhbsOnb2lzIFZhbGVuZHVj?=
	<francois.valenduc@tvcablenet.be>
Subject: Re: [Bugme-new] [Bug 11144] New: dhcp doesn't work with iwl4965
Date: Wed, 23 Jul 2008 17:58:03 +0200
Message-ID: <4887550B.2070704@tvcablenet.be>
References: <bug-11144-10286@http.bugzilla.kernel.org/>	<20080722034850.dbbc5566.akpm@linux-foundation.org>	<4886E49D.6010700@tvcablenet.be> <20080723010522.389a948f.akpm@linux-foundation.org> <4886F727.6010301@tvcablenet.be> <48870425.50908@trash.net> <48871632.3010205@tvcablenet.be> <4887169B.6090102@trash.net> <488725D5.8030900@tvcablenet.be> <488727B3.7040007@trash.net> <48872968.9000103@trash.net> <488746DF.1050501@tvcablenet.be> <48874BD8.60600@trash.net> <48874C12.10606@trash.net> <4887514C.6080903@tvcablenet.be> <488753C6.2090807@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>,
	bugme-daemon@bugzilla.kernel.org, linux-wireless@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ananke.telenet-ops.be ([195.130.137.78]:46434 "EHLO
	ananke.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751089AbYGWP6H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2008 11:58:07 -0400
In-Reply-To: <488753C6.2090807@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy a =C3=A9crit :
> Fran=C3=A7ois Valenduc wrote:
>> Patrick McHardy a =C3=A9crit :
>>>> I think I know whats happening (Jussi CCed). That commit introduce=
d
>>>> a qdisc_skb_cb, which conflicts with the mac80211 usage of skb->cb=
=2E
>>>> mac80211 seems to expect the CB to survive the qdisc layer, which
>>>> is wrong. One possibility to fix this (or just test my theory)
>>>> would be to make sure they don't clash by adding the struct
>>>> ieee80211_tx_info to qdisc_skb_cb->data. Something like this patch=
=2E
>>>>
>>>
>> I tested your last patch. Unfortunately, I get the following compile=
=20
>> error:
>>
>> In file included from net/mac80211/main.c:11:
>> include/net/mac80211.h: In function =E2=80=98IEEE80211_SKB_CB=E2=80=99=
:
>> include/net/mac80211.h:347: erreur: size of array =E2=80=98type name=
=E2=80=99 is=20
>> negative
>
>
> I was afraid that might happen. This means skb->cb is not large
> enough to hold both the qdisc and the ieee80211 structs.
>
> Just for testing, changing (include/net/mac80211.h):
>
> #define IEEE80211_TX_INFO_DRIVER_DATA_SIZE \
>         (sizeof(((struct sk_buff *)0)->cb) - 8)
>
> to
>
> #define IEEE80211_TX_INFO_DRIVER_DATA_SIZE \
>         (sizeof(((struct sk_buff *)0)->cb) - 12)
>
> might help to get it to compile. If that doesn't work, try -16.
>
>
That didn't work, neither with -12 or -16.

