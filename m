From: Jussi Kivilinna <jussi.kivilinna@iki.fi>
Subject: Re: tc linklayer ADSL calc broken after commit 56b765b79 (htb: improved
 accuracy at high rates)
Date: Thu, 30 May 2013 19:29:06 +0300
Message-ID: <51A77E52.2040205@iki.fi>
References: <20130529151330.22c5c89e@redhat.com> <1369842724.5109.44.camel@edumazet-glaptop> <20130530095117.503eeee7@redhat.com> <1369924750.5109.91.camel@edumazet-glaptop> <20130530175559.7cbb6851@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	David Miller <davem@redhat.com>, j.vimal@gmail.com,
	Michal Soltys <soltys@ziu.info>,
	Mike Frysinger <vapier@gentoo.org>,
	Jussi Kivilinna <jussi.kivilinna@mbnet.fi>,
	Patrick McHardy <kaber@trash.net>,
	Jiri Pirko <jpirko@redhat.com>,
	=?UTF-8?B?VG9rZSBIw7hpbGFuZC1Kw7hyZ2Vuc2U=?= =?UTF-8?B?bg==?=
	<toke@toke.dk>, Dave Taht <dave.taht@gmail.com>,
	netdev@vger.kernel.org, bloat@lists.bufferbloat.net,
	Dan Siemon <dan@coverfire.com>,
	Jim Gettys <jg@freedesktop.org>,
	Steven Barth <cyrus@openwrt.org>, Felix Fietkau <nbd@nbd.name>,
	Jiri Benc <jbenc@redhat.com>
To: Jesper Dangaard Brouer <jbrouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sypressi.dnainternet.net ([83.102.40.135]:58730 "EHLO
	sypressi.dnainternet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935436Ab3E3QgI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 May 2013 12:36:08 -0400
In-Reply-To: <20130530175559.7cbb6851@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 30.05.2013 18:55, Jesper Dangaard Brouer wrote:
> On Thu, 30 May 2013 07:39:10 -0700
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
>> On Thu, 2013-05-30 at 09:51 +0200, Jesper Dangaard Brouer wrote:
>>> On Wed, 29 May 2013 08:52:04 -0700
>>> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>>
>>>> I am not sure it will solve the ATM logic (with the 5 bytes
>>>> overhead per 48 bytes cell)
>>>
>>> Are you talking about, that for GSO frames we are not adding a encap
>>> overhead to each "sub" skb.
>>
>> This part is now done properly in qdisc_pkt_len_init() since linux-3.9
> 
> Thanks for the pointer, but qdisc_pkt_len_init() only adds the
> EthMAC+IP+TCP header size for each GSO segment (stored in
> qdisc_skb_cb(skb)->pkt_len).
> It is still missing the AAL5 encapsulation overhead per GSO segment.
> 
> Besides I can see that __qdisc_calculate_pkt_len() "forgets" this
> information and overwrites qdisc_skb_cb(skb)->pkt_len (iif a stab is
> defined on the qdisc).
> 

Maybe change qdisc_pkt_len_init() to take the additional overhead value as
input and change __qdisc_calculate_pkt_len() use

	qdisc_pkt_len_init(skb, stab->szopts.overhead);

instead of

	pkt_len = skb->len + stab->szopts.overhead;

-Jussi
