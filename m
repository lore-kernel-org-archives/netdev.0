From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: fix tcp_trim_head() to adjust segment count with
 skb MSS
Date: Mon, 30 Jan 2012 12:43:38 -0500 (EST)
Message-ID: <20120130.124338.2160187165526498508.davem@davemloft.net>
References: <1327807786-27185-1-git-send-email-ncardwell@google.com>
	<alpine.DEB.2.00.1201300903040.12992@melkinpaasi.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ncardwell@google.com, netdev@vger.kernel.org, nanditad@google.com,
	ycheng@google.com, therbert@google.com
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40009 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752935Ab2A3Rnv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2012 12:43:51 -0500
In-Reply-To: <alpine.DEB.2.00.1201300903040.12992@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Mon, 30 Jan 2012 09:08:51 +0200 (EET)

> On Sat, 28 Jan 2012, Neal Cardwell wrote:
>=20
>> This commit fixes tcp_trim_head() to recalculate the number of
>> segments in the skb with the skb's existing MSS, so trimming the hea=
d
>> causes the skb segment count to be monotonically non-increasing - it
>> should stay the same or go down, but not increase.
>>=20
>> Previously tcp_trim_head() used the current MSS of the connection. B=
ut
>> if there was a decrease in MSS between original transmission and ACK
>> (e.g. due to PMTUD), this could cause tcp_trim_head() to
>> counter-intuitively increase the segment count when trimming bytes o=
ff
>> the head of an skb. This violated assumptions in tcp_tso_acked() tha=
t
>> tcp_trim_head() only decreases the packet count, so that packets_ack=
ed
>> in tcp_tso_acked() could underflow, leading tcp_clean_rtx_queue() to
>> pass u32 pkts_acked values as large as 0xffffffff to
>> ca_ops->pkts_acked().
>>=20
>> As an aside, if tcp_trim_head() had really wanted the skb to reflect
>> the current MSS, it should have called tcp_set_skb_tso_segs()
>> unconditionally, since a decrease in MSS would mean that a
>> single-packet skb should now be sliced into multiple segments.
>>=20
>> Signed-off-by: Neal Cardwell <ncardwell@google.com>
 ...
> Acked-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied, thanks everyone.
