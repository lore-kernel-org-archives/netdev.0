From: Alessandro Suardi <alessandro.suardi@gmail.com>
Subject: Re: [PATCH] ipv4: fix fib metrics
Date: Thu, 24 Mar 2011 23:11:06 +0100
Message-ID: <AANLkTin_gxMF1hyK_yhN+G9UGfcBKAhPE24r7tLe5j3D@mail.gmail.com>
References: <AANLkTik6+TrjiC6ZF+KHhZ1iPzEe2jDayr363C0HgQN4@mail.gmail.com>
	<1300980118.3747.42.camel@edumazet-laptop>
	<AANLkTikZhT5LaA-UEXniDvkneH8JScaVaCaCd4LT59cV@mail.gmail.com>
	<1300983340.3747.44.camel@edumazet-laptop>
	<1300986084.3747.101.camel@edumazet-laptop>
	<AANLkTik+Rf45wUxN86t+Zp7+AXjcJsy0vmZgvmLj-95x@mail.gmail.com>
	<1300992308.3747.205.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1300992308.3747.205.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 24, 2011 at 7:45 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le jeudi 24 mars 2011 =E0 19:14 +0100, Alessandro Suardi a =E9crit :
>
>>
>> I will however make one more bug report, as vpnc is broken before
>> =A0and after this patch - have to dig out what vpnc-script tries to =
do,
>> =A0which results in
>>
>> Error: either "to" is duplicate, or "ipid" is a garbage.
>>
>> =A0after establishing the VPN tunnel.
>>
>
> try following patch
>
> http://git2.kernel.org/?p=3Dlinux/kernel/git/davem/net-2.6.git;a=3Dco=
mmit;h=3D406b6f974dae76a5b795d5c251d11c979a4e509b

That one doesn't work.

On a -git14 kernel + both the fib metrics and the above git diff, I
strace'd vpnc
 and found out this (first triplet of public IP masked intentionally)

[root@duff tmp]# egrep 'execve|garbage' strace.log |egrep '/ip|garbage'
[pid  4228] execve("/sbin/ip", ["/sbin/ip", "route", "get",
"xxx.9.13.212"], [/* 32 vars */]) =3D 0
[pid  4231] execve("/sbin/ip", ["/sbin/ip", "route", "replace",
"10.175.0.0/19", "dev", "tun0"], [/* 32 vars */]) =3D 0
[pid  4232] execve("/sbin/ip", ["/sbin/ip", "route", "flush",
"cache"], [/* 32 vars */]) =3D 0
[pid  4234] execve("/sbin/ip", ["/sbin/ip", "route", "get",
"xxx.9.13.212"], [/* 32 vars */]) =3D 0
[pid  4237] execve("/sbin/ip", ["/sbin/ip", "route", "add",
"xxx.9.13.212", "via", "192.168.1.1", "dev", "eth1", "src",
"192.168.1.8", "ipid", "0x043f", "advmss", "1400"], [/* 32 vars */]) =3D
0
[pid  4237] write(2, "Error: either \"to\" is duplicate,"..., 57Error:
either "to" is duplicate, or "ipid" is a garbage.

192.168.1.1 is my DSL router and 192.168.1.8 is my computer's wireless =
IP.

Does this ring any bell ?


Thanks,

--alessandro

=A0"There's always a siren singing you to shipwreck"

=A0=A0 (Radiohead, "There There")
