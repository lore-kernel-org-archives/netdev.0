From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] vlan: Fix the ingress VLAN_FLAG_REORDER_HDR check
Date: Sat, 11 Jun 2011 16:16:07 -0700 (PDT)
Message-ID: <20110611.161607.527234711460805217.davem@davemloft.net>
References: <BANLkTinctdoyYJo+sU9qUWV8uZV8yGNdnw@mail.gmail.com>
	<20110610165656.GA25677@minipsycho.redhat.com>
	<BANLkTi=LeDecHK4x+6qa-q2h5Duub4zoTg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jpirko@redhat.com, pratnakarlx@gmail.com, ebiederm@xmission.com,
	shemminger@linux-foundation.org, greearb@candelatech.com,
	nicolas.2p.debian@gmail.com, netdev@vger.kernel.org,
	kaber@trash.net, fubar@us.ibm.com, eric.dumazet@gmail.com,
	andy@greyhouse.net, jesse@nicira.com
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41784 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751730Ab1FKXR2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jun 2011 19:17:28 -0400
In-Reply-To: <BANLkTi=LeDecHK4x+6qa-q2h5Duub4zoTg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Changli Gao <xiaosuo@gmail.com>
Date: Sat, 11 Jun 2011 08:05:37 +0800

> On Sat, Jun 11, 2011 at 12:56 AM, Jiri Pirko <jpirko@redhat.com> wrot=
e:
>> This time heavily based on Eric's V2. mac_len is reset at appropriat=
e
>> places. Also skb->data is adjusted to point to beginning of mac head=
er
>> before calling vlan_insert_tag.
>>
>> Please review (fingers crossed).
>>
>> Subject: [patch net-2.6 v2.1] vlan: Fix the ingress VLAN_FLAG_REORDE=
R_HDR check
>>
>> Testing of VLAN_FLAG_REORDER_HDR does not belong in vlan_untag
>> but rather in vlan_do_receive. =A0Otherwise the vlan header
>> will not be properly put on the packet in the case of
>> vlan header accelleration.
>>
>> As we remove the check from vlan_check_reorder_header
>> rename it vlan_reorder_header to keep the naming clean.
>>
>> Fix up the skb->pkt_type early so we don't look at the packet
>> after adding the vlan tag, which guarantees we don't goof
>> and look at the wrong field.
>>
>> Use a simple if statement instead of a complicated switch
>> statement to decided that we need to increment rx_stats
>> for a multicast packet.
>>
>> Hopefully at somepoint we will just declare the case where
>> VLAN_FLAG_REORDER_HDR is cleared as unsupported and remove
>> the code. =A0Until then this keeps it working correctly.
>>
>> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
>> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
> Acked-by: Changli Gao <xiaosuo@gmail.com>

Applied, great work everyone.
