From: "Martitz, Thomas" <thomas.martitz@hhi.fraunhofer.de>
Subject: AW: AW: Trying to implement secondary loopback
Date: Wed, 13 Mar 2013 22:01:00 +0000
Message-ID: <3D7E565A361FB844A410A5EFCDD7BA4002F351@MXSRV3.fe.hhi.de>
References: <513F1A17.1000809@hhi.fraunhofer.de>
	<CAFLxGvxcyDVwC-iys6UdKMBB6u3UQx6s7-mwm5caoNu=N7rmeA@mail.gmail.com>
	<3D7E565A361FB844A410A5EFCDD7BA4002ECF5@MXSRV3.fe.hhi.de>
	<87r4jjav00.fsf@xmission.com>
	<3D7E565A361FB844A410A5EFCDD7BA4002EF11@MXSRV3.fe.hhi.de>,<878v5r9es7.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: richard -rw- weinberger <richard.weinberger@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"edumazet@google.com" <edumazet@google.com>,
	"herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.HHI.FRAUNHOFER.DE ([193.174.67.45]:37075 "EHLO
	mailgw.hhi.fraunhofer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933273Ab3CMWBE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Mar 2013 18:01:04 -0400
In-Reply-To: <878v5r9es7.fsf@xmission.com>
Content-Language: de-DE
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> ________________________________________
> Von: Eric W. Biederman [ebiederm@xmission.com]
> Gesendet: Mittwoch, 13. M=E4rz 2013 22:21
> An: Martitz, Thomas
> Cc: richard -rw- weinberger; netdev@vger.kernel.org; davem@davemloft.=
net; edumazet@google.com; herbert@gondor.apana.org.au
> Betreff: Re: AW: Trying to implement secondary loopback
>
> "Martitz, Thomas" <thomas.martitz@hhi.fraunhofer.de> writes:
>
> >> Von: Eric W. Biederman [ebiederm@xmission.com]
> >>
> >> The easy solution is to setup two network namespaces and two nics.
> >> And transmit data from one network namespace to another, through y=
our
> >> nics.
>
> >
> > That sounds a lot more involed than using loopback to send data bac=
k
> > to the same process. And I guess just calling netif_rx() in the xmi=
t()
> > function wouldn't be sufficient either? Also I wouldn't know how to=
 do
> > that as I'm not yet very familiar with network namespaces (but that
> > can clearly get fixed).
>
> It may sound involved but it is just a few lines of code to set up.
>
> ip netns add ns1
> ip netns add ns2
> ip link set nic1 netns ns1
> ip link set nic2 netns ns2
>
> int main(int argc, char **argv)
> {
>         int netfd1, netfd2;
>         int sk1, sk2;
>         netfd1 =3D open(/var/run/netns/nic1);
>         netfd2 =3D open(/var/run/netns/nic2);
>
>         setns(netfd1, 0);
>         sk1 =3D socket(...);
>
>         setns(netfd2, 0);
>         sk2 =3D socket(...);
>
>         /* test test test */
> }
>
> And what is partidcularly interesting is that all of this works with
> your drivers normal code paths without any kernel hacks.
>

Thanks for the info, sounds very interesting. Now, how do I provide mul=
tiple interfaces within a single kernel module. Just call register_netd=
ev() multiple times?

Best regards.
-----
visit us at

OFC 2013 / March 19-21 / Anaheim Convention Center, CA, USA / booth 118=
07

www.hhi.fraunhofer.de/events
