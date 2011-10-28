From: David Miller <davem@davemloft.net>
Subject: Re: [RFC v2] tcp: Export TCP Delayed ACK parameters to user
Date: Fri, 28 Oct 2011 18:31:07 -0400 (EDT)
Message-ID: <20111028.183107.2091450715774357523.davem@davemloft.net>
References: <1319836443-4419-1-git-send-email-dbaluta@ixiacom.com>
	<20111028.171904.1635229691857703124.davem@davemloft.net>
	<CAEnQRZCxSPb8NRceB+tfdZnkN=K-jGbdmXDgNwEhZFYAWGmvAg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	luto@amacapital.net, rick.jones2@hp.com
To: dbaluta@ixiacom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:42452 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754492Ab1J1WeG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Oct 2011 18:34:06 -0400
In-Reply-To: <CAEnQRZCxSPb8NRceB+tfdZnkN=K-jGbdmXDgNwEhZFYAWGmvAg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Daniel Baluta <dbaluta@ixiacom.com>
Date: Sat, 29 Oct 2011 00:35:24 +0300

> On Sat, Oct 29, 2011 at 12:19 AM, David Miller <davem@davemloft.net> =
wrote:
>> From: Daniel Baluta <dbaluta@ixiacom.com>
>> Date: Sat, 29 Oct 2011 00:14:03 +0300
>>
>>> +static inline int tcp_delack_thresh(const struct sock *sk)
>>> +{
>>> + =A0 =A0 return inet_csk(sk)->icsk_ack.rcv_mss * sysctl_tcp_delack=
_segs;
>>> +}
>>> +
>>
>> Please turn this into a shift or something, you're adding a multiply
>> into a core code path.
>=20
> Is there any generic API to do this? Default case is not
> affected since tcp_delack_segs is 1.

I'm saying make the tunable a shift count instead of something to
multiply against.
