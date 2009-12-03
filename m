From: "Chris Friesen" <cfriesen@nortel.com>
Subject: Re: seeing strange values for tcp sk_rmem_alloc
Date: Thu, 03 Dec 2009 15:40:41 -0600
Message-ID: <4B183059.4070109@nortel.com>
References: <4B15416A.2060202@nortel.com> <4B154B29.1030807@cosmosbay.com> <4B155252.1040604@nortel.com> <4B1557CC.4060503@gmail.com> <4B17ED8D.7050409@nortel.com> <4B17EF8E.60704@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Linux kernel <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754637AbZLCVnQ@vger.kernel.org>
In-Reply-To: <4B17EF8E.60704@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/03/2009 11:04 AM, Eric Dumazet wrote:
> Chris Friesen a =E9crit :

>> Ah, that makes a difference.  But the results (see below) still
>> look odd.  For this test, /proc/sys/net/core/rmem_default is
>> 118784.  For some reason sk_rmem_alloc gets bumped by 16KB when I
>> only send 2KB of data, and it drops back down again every 6
>> packets.

>=20
> Might be because you use loopback device ? ;)
>=20
> ifconfig lo | grep MTU UP LOOPBACK RUNNING  MTU:16436  Metric:1
>=20
> After a while (when hitting rcvbuf limit), tcp stack performs skb
> collapses, to reduce ram usage.

Looks like this is indeed the case, changing the loopback mtu to 8K
makes it increase in 8K increments.  This is quite unexpected, since fo=
r
UDP it only increases by the actual amount of the data being sent rathe=
r
than the size of the full MTU.

As it stands, it looks like sk_rmem_alloc isn't very useful.  Can you
point me to something that is more reflective of the actual space used
by the tcp socket?  I'd like something that increases monotonically wit=
h
received data and once it exceeds the configured size then the tcp stac=
k
will start dropping packets.  Does such a thing exist, or is the tcp
stack just too complicated to easily obtain this sort of information?

Thanks for your help,

Chris
