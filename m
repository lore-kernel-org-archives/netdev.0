From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [PATCH 1/3] vlan: Do not support clearing VLAN_FLAG_REORDER_HDR
Date: Tue, 24 May 2011 09:19:55 +0200
Message-ID: <4DDB5C1B.9000207@gmail.com>
References: <m1ei3qjzix.fsf_-_@fess.ebiederm.org> <4DD97A44.2020708@candelatech.com> <m1wrhigy37.fsf@fess.ebiederm.org> <BANLkTinXFYzzj3R97mKH-90xM64BDwN8aA@mail.gmail.com> <BANLkTik6etR8V1qeDnYBKt6BaODBe8kUOw@mail.gmail.com> <m1ei3qdwa6.fsf@fess.ebiederm.org> <BANLkTi=BN6Aza7eU=D+WqJgVsVuswT5PDg@mail.gmail.com> <m139k57nzx.fsf@fess.ebiederm.org> <20110523104339.GA2769@psychotron> <4DDAB9FC.8050207@gmail.com> <20110524055836.GA2955@psychotron>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Changli Gao <xiaosuo@gmail.com>,
	Ben Greear <greearb@candelatech.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	shemminger@linux-foundation.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, andy@greyhouse.net,
	Jesse Gross <jesse@nicira.com>
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:57954 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753359Ab1EXHT5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2011 03:19:57 -0400
Received: by wwa36 with SMTP id 36so6996408wwa.1
        for <netdev@vger.kernel.org>; Tue, 24 May 2011 00:19:56 -0700 (PDT)
In-Reply-To: <20110524055836.GA2955@psychotron>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 24/05/2011 07:58, Jiri Pirko a =E9crit :
<snip>

>>> Btw what's the rationale to move untag to earlier position?
>>
>> Maybe simply because we try to mimic hw-accel, and hw-accel untaggin=
g
>> definitely happens before we enter __netif_receive_skb and only
>> happens once.
>>
>> So having software untagging inside the __netif_receive_skb loop loo=
ks different.
>
> I understand. But what code prior to current vlan_untag position need=
s
> to see the skb untagged?

Any protocol handlers (ptype_all or ptype_base) registered on the paren=
t interface may need to see=20
the skb untagged, for all the reasons given in this thread. Arguably, d=
oing software untagging=20
earlier wouldn't help. :-) We need a strong logic to decide whether and=
 when to untag and/or=20
possibly re-tag.

	Nicolas.
