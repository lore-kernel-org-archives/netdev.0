From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH net-next-2.6] pktgen: Optionally leak kernel memory
Date: Sat, 24 Jul 2010 08:35:35 -0700
Message-ID: <4C4B0847.4050001@candelatech.com>
References: <4C4A224B.8080806@candelatech.com>	 <1279949024.2451.43.camel@edumazet-laptop>	 <4C4AE80F.1040406@candelatech.com> <1279980795.2451.157.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, NetDev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:33429 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752860Ab0GXPfp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Jul 2010 11:35:45 -0400
In-Reply-To: <1279980795.2451.157.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/24/2010 07:13 AM, Eric Dumazet wrote:
> Le samedi 24 juillet 2010 =C3=A0 06:18 -0700, Ben Greear a =C3=A9crit=
 :
>
>> I think most users of pktgen wouldn't be too concerned about leaking
>> memory content to the network.  It's a root-only test tool that can =
easily
>> saturate most networks and do horrible things like overflow switch C=
AM tables
>> by randomizing source/dest macs etc.  So, this warning might could b=
e a bit
>> more descriptive of how it is a security problem "arbitrary contents=
 of memory can be
>> sent across the network and may be sniffed by devices on the network=
, potentially
>> revealing private information such as passwords and application data=
 for applications
>> running on the machine running pktgen" instead of telling folks not =
to use it unless it's
>> really needed.
>
> Most of the horrible things you mention are not related to the memset=
()
> thing, arent they ?
>
>
> Being root means : "I am a trusted user on this machine, and as such,
> must know a bit what security means".
>
> It doesnt mean : "I am allowed to steal passwords, credit card number=
s,
> from gentle users. I am allowed to blow up the LAN with billions of e=
vil
> frames". Still, pktgen is there and might be used by a fool.

Out of curiosity, couldn't root just use gdb, strace or similar means t=
o
get access to user's programs?  Or add a simple module to the kernel to
dump memory pages for that matter?

It would seem to me that this UNSAFE flag is only to protect root users=
 from
accidentally sharing their own private memory accidentally.

> The "UNSAFE" label should be more than enough to warn the fool admin =
;)
>
> Note this "UNSAFE" thing is really bad. Nowhere in the kernel we are
> allowed to make this sort of thing : No special mmap() flag asking
> kernel to give non cleared memory pages, even to root user.

Ok, I don't mind either way.  I have a bunch of hacks to pktgen in
my tree already, so one more isn't a big deal.

> Anyway, as I said, if you want to saturate a 10Gb+ network with pktge=
n,
> you probably need clone_skb ?

I can get bi-directional 9.6Gbps or so using 1514 byte pkts and clone-s=
kb =3D=3D 0
on two ports using Intel 82599 10G NIC on core-i7 3.33Ghz (6GT/s pci-e =
bus).
(with memsets commented out).  This is around 40Gbps total data across =
the network
interfaces.

Some day I'll get a quad or 6-port 10G and see what it can do :)

Thanks,
Ben

--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
