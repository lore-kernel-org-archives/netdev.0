From: Plamen Petrov <pvp-lsts@fs.uni-ruse.bg>
Subject: Re: [Bugme-new] [Bug 16626] New: Machine hangs with EIP at skb_copy_and_csum_dev
Date: Fri, 20 Aug 2010 10:38:12 +0300
Message-ID: <4C6E30E4.2040908@fs.uni-ruse.bg>
References: <bug-16626-10286@https.bugzilla.kernel.org/>	 <20100819152143.8a57c465.akpm@linux-foundation.org>	 <4C6E0C99.2060407@fs.uni-ruse.bg>	 <20100819221142.b8f6a70a.akpm@linux-foundation.org>	 <4C6E1CBA.2060605@fs.uni-ruse.bg>	 <20100819232019.6f6074a8.akpm@linux-foundation.org>	 <4C6E202E.5030406@fs.uni-ruse.bg> <1282286070.2295.6.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [83.228.35.12] ([83.228.35.12]:44396 "EHLO fs.ru.acad.bg"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750849Ab0HTHiP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Aug 2010 03:38:15 -0400
In-Reply-To: <1282286070.2295.6.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=D0=9D=D0=B0 20.8.2010 =D0=B3. 09:34, Eric Dumazet =D0=BD=D0=B0=D0=BF=D0=
=B8=D1=81=D0=B0:
> Le vendredi 20 ao=C3=BBt 2010 =C3=A0 09:26 +0300, Plamen Petrov a =C3=
=A9crit :
>> Posting this only in the hope that it will be helpfull to the
>> "net guys"...
>
> Its a forwarding setup.
>
> Please post
>
> ifconfig -a
> iptables -nvL
> iptables -t nat -nvL
> iptables -t mangle -nvL
> ip route
> ethtool -k eth0   (&  eth1 ...)
>
> Try to disable gro ?
> ethtool -K eth0 gro off
> ethtool -K eth1 gro off
>
>
Sorry about this, but when I dig a bit into this, I found that
I had a pretty old ethtool:
> root@fs:~# ethtool --help
> ethtool version 5
> Usage:
> ethtool DEVNAME Display standard information about device
> ...

So my ethtool did not know anything about gro, because by
looking at
http://git.kernel.org/?p=3Dnetwork/ethtool/ethtool.git;a=3Dshortlog
I saw I had this one:
2006-09-01	Jeff Garzik	Release version 5. origin v5
and gro reading/setting was added "a bit later"...
2009-03-06	Jeff Garzik	Get/set GRO settings.

So, I went on and compiled myself a new ethtool:
> root@fs:~# ethtool -h
> ethtool version 2.6.35
> Usage:
> ethtool DEVNAME Display standard information about device
> ...
And run it on my 2.6.34.4 kernel, which produced these:
>
root@fs:~# ethtool -k eth0
> Offload parameters for eth0:
> rx-checksumming: on
> tx-checksumming: on
> scatter-gather: on
> tcp-segmentation-offload: off
> udp-fragmentation-offload: off
> generic-segmentation-offload: on
> generic-receive-offload: off
> large-receive-offload: off
> ntuple-filters: off
> receive-hashing: off
root@fs:~# ethtool -k eth1
> Offload parameters for eth1:
> rx-checksumming: on
> tx-checksumming: on
> scatter-gather: on
> tcp-segmentation-offload: on
> udp-fragmentation-offload: off
> generic-segmentation-offload: on
> generic-receive-offload: off
> large-receive-offload: off
> ntuple-filters: off
> receive-hashing: off
root@fs:~# ethtool -k eth2
> Offload parameters for eth2:
> rx-checksumming: on
> tx-checksumming: on
> scatter-gather: on
> tcp-segmentation-offload: off
> udp-fragmentation-offload: off
> generic-segmentation-offload: on
> generic-receive-offload: off
> large-receive-offload: off
> ntuple-filters: off
> receive-hashing: off
root@fs:~#
>
But again, this is on 2.6.34.4. Could it be that
"generic-receive-offload" is ON by default on my
only gigabit capable tg3 card on 2.6.35.x and later?

I will try to determine this myself later, but the
machine is a gateway on the local area network, and
is needed from the user here...

Thanks!
