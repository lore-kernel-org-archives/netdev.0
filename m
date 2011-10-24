From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/3] net: hold sock reference while processing tx
 timestamps
Date: Mon, 24 Oct 2011 02:55:17 -0400 (EDT)
Message-ID: <20111024.025517.2214073425674839704.davem@davemloft.net>
References: <cover.1319193734.git.richard.cochran@omicron.at>
	<f13715e7d094e7989581f5eacf0efe9d15379e10.1319193734.git.richard.cochran@omicron.at>
	<1319196710.2338.26.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: richardcochran@gmail.com, netdev@vger.kernel.org,
	johannes@sipsolutions.net, stable@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44365 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753227Ab1JXG4Y convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Oct 2011 02:56:24 -0400
In-Reply-To: <1319196710.2338.26.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 21 Oct 2011 13:31:50 +0200

> Le vendredi 21 octobre 2011 =E0 12:49 +0200, Richard Cochran a =E9cri=
t :
>> The pair of functions,
>>=20
>>  * skb_clone_tx_timestamp()
>>  * skb_complete_tx_timestamp()
>>=20
>> were designed to allow timestamping in PHY devices. The first
>> function, called during the MAC driver's hard_xmit method, identifie=
s
>> PTP protocol packets, clones them, and gives them to the PHY device
>> driver. The PHY driver may hold onto the packet and deliver it at a
>> later time using the second function, which adds the packet to the
>> socket's error queue.
>>=20
>> As pointed out by Johannes, nothing prevents the socket from
>> disappearing while the cloned packet is sitting in the PHY driver
>> awaiting a timestamp. This patch fixes the issue by taking a referen=
ce
>> on the socket for each such packet. In addition, the comments
>> regarding the usage of these function are expanded to highlight the
>> rule that PHY drivers must use skb_complete_tx_timestamp() to releas=
e
>> the packet, in order to release the socket reference, too.
>>=20
>> These functions first appeared in v2.6.36.
>>=20
>> Reported-by: Johannes Berg <johannes@sipsolutions.net>
>> Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
>> Cc: <stable@vger.kernel.org>
>> ---
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
