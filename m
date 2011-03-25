From: Alessandro Suardi <alessandro.suardi@gmail.com>
Subject: Re: [PATCH] ipv4: fix fib metrics
Date: Fri, 25 Mar 2011 01:12:11 +0100
Message-ID: <AANLkTi=Xb3KCBKoVCcaVD5iyCtMCAnYaGF_DTeFQ0ays@mail.gmail.com>
References: <1301005107.2714.113.camel@edumazet-laptop>
	<AANLkTinv+XGBjbFoK6vpyiDW6gBEBKFjUef+mCAMJU9i@mail.gmail.com>
	<1301005946.2714.130.camel@edumazet-laptop>
	<20110324.153623.45921344.davem@davemloft.net>
	<1301006652.2714.145.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:58975 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755150Ab1CYAML convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2011 20:12:11 -0400
In-Reply-To: <1301006652.2714.145.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 24, 2011 at 11:44 PM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> Le jeudi 24 mars 2011 =E0 15:36 -0700, David Miller a =E9crit :
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Thu, 24 Mar 2011 23:32:26 +0100
>>
>> > Then it doesnt work anymore because it parses an ipip field from
>> > ip route get ...
>> >
>> > $ ip ro get 192.168.1.1
>> > 192.168.1.1 dev wlan0 =A0src 192.168.1.21
>> > =A0 =A0 cache =A0ipid 0x784c mtu 1500 advmss 1460 hoplimit 64
>> >
>> >
>> > Maybe you upgraded iproute2
>>
>> I'm leaning towards app bug too.
>>
>> These default metrics wouldn't get printed before, but now because o=
f
>> how metrics are handled, they will.
>>
>> Userland needs to cope properly with this.
>
>
> BTW, ipip is not always printed (even on old kernels) : One needs to
> actually need ipip generation .
>
> edumazet@edumazet-laptop:~$ ping 4.4.4.4
> PING 4.4.4.4 (4.4.4.4) 56(84) bytes of data.
> ^C
>
> edumazet@edumazet-laptop:~$ ip ro get 4.4.4.4
> 4.4.4.4 dev ppp0 =A0src 10.150.51.210
> =A0 =A0cache =A0mtu 1500 advmss 1460 hoplimit 64
>
> edumazet@edumazet-laptop:~$ ping -s 2000 4.4.4.4
> PING 4.4.4.4 (4.4.4.4) 2000(2028) bytes of data.
> ^C
>
> edumazet@edumazet-laptop:~$ ip ro get 4.4.4.4
> 4.4.4.4 dev ppp0 =A0src 10.150.51.210
> =A0 =A0cache =A0ipid 0xf99a mtu 1500 advmss 1460 hoplimit 64
>
>
> This on a 2.6.35 kernel
>
> I suspect Alessandro tool had a bug anyway.

I still contend this is a kernel regression :)


vpnc is a custom build from trunk as of June 2010, with openssl support
 to talk to my corporate VPN concentrator:

[root@duff oldconfigs]# vpnc --version
vpnc version 0.5.3-449M
Copyright (C) 2002-2006 Geoffrey Keating, Maurice Massar, others
vpnc comes with NO WARRANTY, to the extent permitted by law.
You may redistribute copies of vpnc under the terms of the GNU General
Public License.  For more information about these matters, see the file=
s
named COPYING.
Built with openssl certificate support. Be aware of the
license implications.

Supported DH-Groups: nopfs dh1 dh2 dh5
Supported Hash-Methods: md5 sha1
Supported Encryptions: null des 3des aes128 aes192 aes256
Supported Auth-Methods: psk psk+xauth hybrid(rsa)


My iproute package, on this up-to-date Fedora 14 x86_64, has last been
 updated on 20 Nov 2010, and back then I was running 2.6.37-rc2-git4
 (I keep around my historical .config files, so I know for sure).

[root@duff ~]# ip -V
ip utility, iproute2-ss100804
[root@duff ~]# rpm -qf /sbin/ip
iproute-2.6.35-6.fc14.x86_64

The behavior of this version of 'ip' as invoked by this version of 'vpn=
c'
 is something that has worked for the last 4 months, and isn't working
 right now. Furthermore, previous versions of 'ip' in Fedora 14 were
 also working with the same 'vpnc', which means it's actually 9 months
 minimum of working behavior.

If some change in the kernel broke my userspace, this usually qualifies
 as a regression.


That said, if you can point me to a working version of iproute with the
 current kernel, I have no problem in upgrading it :)

Thanks,

--alessandro

=A0"There's always a siren singing you to shipwreck"

=A0=A0 (Radiohead, "There There")
