From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: PROBLEM: kernel oops when tickless. 2.6.28.x to 2.6.31.3
Date: Tue, 13 Oct 2009 16:51:24 +0200
Message-ID: <4AD493EC.9000608@gmail.com>
References: <20091013090554.GB28715@taz.net.au> <4AD45169.2030507@gmail.com> <20091013141434.GA10613@taz.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Craig Sanders <cas@taz.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:38876 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760048AbZJMOwL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2009 10:52:11 -0400
In-Reply-To: <20091013141434.GA10613@taz.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Craig Sanders a =E9crit :
> On Tue, Oct 13, 2009 at 12:07:37PM +0200, Eric Dumazet wrote:
>> This particular problem should/could be fixed in 2.6.31.4 by commit=20
>> d99927f4d93f36553699573b279e0ff98ad7dea6
>> (net: Fix sock_wfree() race)
>>
>> Please try to reproduce your tickless problem on 2.6.31.4 or latest
>> Linus git tree
>=20
>=20
> I've already compiled 2.6.31.4 @1000HZ, but I'll compile again and tr=
y
> 2.6.31.4 tickless in the morning. i'll report back with the result - =
it
> usually takes a few days after booting before the Oops occurs, so if =
it
> goes well that might not be until the weekend or early next week.
>=20
> any idea what actually triggers it?  pppoe? malformed packets from th=
e
> internet?  udp/514 packets for rsyslogd?
>=20

Oct 13 14:10:02 taz kernel: [170654.573889]  [<ffffffff81432b43>] ? soc=
k_wfree+0x83/0x90
Oct 13 14:10:02 taz kernel: [170654.573892]  [<ffffffff814370cc>] ? skb=
_release_head_state+0x5c/0x110
Oct 13 14:10:02 taz kernel: [170654.573894]  [<ffffffff81436de9>] ? __k=
free_skb+0x9/0xa0
Oct 13 14:10:02 taz kernel: [170654.573896]  [<ffffffff8143a48c>] ? skb=
_free_datagram+0xc/0x40
Oct 13 14:10:02 taz kernel: [170654.573900]  [<ffffffff814b5102>] ? uni=
x_dgram_recvmsg+0x202/0x330

This stack trace gives a hint on sock_wfree() that was fixed in 2.6.31.=
4

Occurrence of the bug might be related to your PREEMPT setting.

