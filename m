From: Arnd Hannemann <hannemann@nets.rwth-aachen.de>
Subject: Re: scp stalls mysteriously
Date: Thu, 03 Dec 2009 14:37:03 +0100
Message-ID: <4B17BEFF.2030309@nets.rwth-aachen.de>
References: <20091130213727.2f4047d2@houba>
 <alpine.DEB.2.00.0911302244160.9826@melkinpaasi.cs.helsinki.fi>
 <20091201211945.505d3c98@houba>
 <alpine.DEB.2.00.0912012220570.1904@melkinpaasi.cs.helsinki.fi>
 <20091202085925.472136e2@houba>
 <alpine.DEB.2.00.0912021438030.20416@melkinpaasi.cs.helsinki.fi>
 <20091202154403.GB30730@sd-11162.dedibox.fr>
 <alpine.DEB.2.00.0912021745200.7024@wel-95.cs.helsinki.fi>
 <20091202183451.173db5f2@houba> <4B16BD58.3040802@tvk.rwth-aachen.de>
 <20091203085933.GD30730@sd-11162.dedibox.fr>
 <alpine.DEB.2.00.0912031121190.7024@wel-95.cs.helsinki.fi>
 <20091203131127.131e9122@houba>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?B?SWxwbyBKw6RydmluZW4=?= <ilpo.jarvinen@helsinki.fi>,
	Damian Lukowski <damian@tvk.rwth-aachen.de>,
	Netdev <netdev@vger.kernel.org>, Asdo <asdo@shiftmail.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Greg KH <gregkh@suse.de>
To: Frederic Leroy <fredo@starox.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-1.ms.rz.RWTH-Aachen.DE ([134.130.7.72]:64149 "EHLO
	mta-1.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755970AbZLCNhP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 08:37:15 -0500
Received: from ironport-out-1.rz.rwth-aachen.de ([134.130.5.40])
 by mta-1.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0KU200IA8WI9MJ70@mta-1.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Thu, 03 Dec 2009 14:37:21 +0100 (CET)
In-reply-to: <20091203131127.131e9122@houba>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rederic Leroy wrote:
> Le Thu, 3 Dec 2009 12:29:39 +0200 (EET),
> "Ilpo J=C3=A4rvinen" <ilpo.jarvinen@helsinki.fi> a =C3=A9crit :
>=20
>> Opinions, Dave?, Greg?
>>
>> Now back to the issue...
>>
>> You said in the other mail that "All further test are on linus-stabl=
e=20
>> tree.", which has this contradiction that Linus does not maintain
>> stable trees. Which exactly was the tree used for the .9. test
>=20
> Sorry I'm confused and so confuse you.
> For .9 .10 and now I'm only using :=20
> git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git
> =20
>> Linus' tree or the 2.6.31 stable tree? I suppose the former since th=
e
>> revert wouldn't apply to 2.6.31 so I just want to confirm.
>=20
> I didn't keep the source of the old 2.6.31 kernel I have.=20
> So it's either=20
> git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git
> or
> git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-2.6-stable=
=2Egit
>=20
>> Nice thinking indeed Damian, thanks. ...But but, where exactly did
>> you print? ...There are multiple returns and the return false branch
>> is expected to have a zero retrans_stamp in a typical case but that
>> is not a problem because we never use the value.
>=20
> Here is the code :
> http://www.starox.org/pub/scp_stall/printk_retrans_stamp.patch
>=20
>> ...Anyway, if I'm wrong with my suspicion and it still holds that we
>> have zero retrans_stamp in the substraction too, it could have
>> something to do with this snippet:
>>
>> static void tcp_try_to_open(struct sock *sk, int flag)
>> {
>>         struct tcp_sock *tp =3D tcp_sk(sk);
>>
>>         tcp_verify_left_out(tp);
>>
>>         if (!tp->frto_counter && tp->retrans_out =3D=3D 0)
>>                 tp->retrans_stamp =3D 0;
>>
>> ...It bit me last time when FRTO was enabled after very small
>> modification (without running a full verification after the trivial
>> looking modification). ...So I've worked around this clearing for
>> FRTO as you can see :-).
>=20
> :)
>=20
>> Also, we have the another mystery to be solved, the fast
>> retransmission is not triggered for some reason (or alternatively no=
t
>> captured in to a log), even in the working .9. case. It would be eas=
y
>> to see whether it works at all from TCP point of view by looking int=
o
>> mibs once you have have some transfers in a working configuration:
>>
>> grep -A1 TCP /proc/net/netstat
>=20
> I will try this evening. I can do test only outside office hours.

If you don't mind, could you also post the output of
"sysctl -a | grep net.ipv4.tcp", please.
The tars you posted (proc_net_tcp.tbz2) seem to be empty.

Thanks.

Best regards,
Arnd
