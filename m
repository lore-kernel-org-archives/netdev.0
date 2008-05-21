From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [iproute2] get_hz() with CONFIG_HIGH_RES_TIMERS
Date: Wed, 21 May 2008 10:10:53 -0700
Message-ID: <20080521101053.27db3495@extreme>
References: <20080521163815.GA5028@sc.homeunix.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Stephane Chazelas <Stephane_Chazelas@yahoo.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:41214 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751616AbYEURLA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 May 2008 13:11:00 -0400
In-Reply-To: <20080521163815.GA5028@sc.homeunix.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 21 May 2008 17:38:15 +0100
Stephane Chazelas <Stephane_Chazelas@yahoo.fr> wrote:

> Hi Stephen,
>=20
> there seems to be something wrong with the timer values as
> processed by at least the "ss" and "ip" commands when
> CONFIG_HIGH_RES_TIMERS is on.
>=20
> $ zgrep -e HZ=3D -e HIGH_RES /proc/config.gz
> CONFIG_HIGH_RES_TIMERS=3Dy
> CONFIG_HZ=3D250
>=20
> For instance, the "ip route rtt <time>" and=20
> rto values returned by PROC_NET_TCP=3D/proc/net/tcp ss -i
> look incorrect:
>=20
> $ PROC_NET_TCP=3D/proc/net/tcp ss -i
> State       Recv-Q Send-Q  Local Address:Port      Peer Address:Port
> ESTAB       0      0           127.0.0.1:35466        127.0.0.1:10198=
    rto:5.5e-08
> [...]
>=20
> $ ss -i
> State       Recv-Q Send-Q  Local Address:Port      Peer Address:Port
> ESTAB       0      0           127.0.0.1:35466        127.0.0.1:10198
>         bic wscale:7,7 rto:220 rtt:23.5/19 send 11.2Mbps rcv_space:32=
792
>=20
>=20
> $ ip route show
> 10.95.131.111 via 10.95.128.1 dev eth0  rtt 5ms
>=20
> $ netstat -rn
> Kernel IP routing table
> Destination     Gateway         Genmask         Flags   MSS Window  i=
rtt Iface
> 10.95.131.111   10.95.128.1     255.255.255.255 UGH       0 0     500=
0000 eth0
>=20
> I think this is because get_hz gets the HZ value from the fourth
> field in /proc/net/psched. That's 1e9 in my case, because that's
> meant to be the frequency of CLOCK_MONOTONIC and when
> CONFIG_HIGH_RES_TIMERS is on, the CLOCK_MONOTONIC resolution is
> 1ns. So get_hz returns 1,000,000,000 instead of 250 in my case.
>=20
> I don't know how to get the right value, clock_getres return 1ns
> as well.
>=20
> That's with 2.6.24.2, iproute-20080108 from debian (but the GIT
> head code looks the same).
>=20
> Best regards,
> St=C3=A9phane

Several places in iproute utils confuse psched and user hz values.
I am looking into it.

