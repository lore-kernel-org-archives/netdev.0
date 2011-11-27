From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/5] tcp: use SACKs and DSACKs that arrive on ACKs
 below snd_una
Date: Sun, 27 Nov 2011 18:57:29 -0500 (EST)
Message-ID: <20111127.185729.461507155117180287.davem@davemloft.net>
References: <1321469885-10885-1-git-send-email-ncardwell@google.com>
	<1321469885-10885-3-git-send-email-ncardwell@google.com>
	<alpine.DEB.2.00.1111170344580.1205@melkinpaasi.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ncardwell@google.com, netdev@vger.kernel.org, nanditad@google.com,
	ycheng@google.com, therbert@google.com
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47912 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752934Ab1K0X5i convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2011 18:57:38 -0500
In-Reply-To: <alpine.DEB.2.00.1111170344580.1205@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Thu, 17 Nov 2011 03:52:37 +0200 (EET)

> On Wed, 16 Nov 2011, Neal Cardwell wrote:
>=20
>> The bug: When the ACK field is below snd_una (which can happen when
>> ACKs are reordered), senders ignored DSACKs (preventing undo) and di=
d
>> not call tcp_fastretrans_alert, so they did not increment
>> prr_delivered to reflect newly-SACKed sequence ranges, and did not
>> call tcp_xmit_retransmit_queue, thus passing up chances to send out
>> more retransmitted and new packets based on any newly-SACKed packets=
=2E
>>=20
>> The change: When the ACK field is below snd_una (the "old_ack" goto
>> label), call tcp_fastretrans_alert to allow undo based on any
>> newly-arrived DSACKs and try to send out more packets based on
>> newly-SACKed packets.
>>=20
>> Other patches in this series will provide other changes that are
>> necessary to fully fix this problem.
>>=20
>> Signed-off-by: Neal Cardwell <ncardwell@google.com>
 ...
> Acked-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied to net-next.

> ...unrelated to the fix, I realized that FRTO is not fully thought th=
rough=20
> in this old ACK case, also its RFC seems to lack considerations on wh=
at to=20
> do in such case. ...I'll need to think the FRTO stuff a bit more.

Every feature added to TCP beginning with timestamps has not been well
thought out wrt. reordering. :-)
