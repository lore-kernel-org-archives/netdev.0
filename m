From: Alessandro Suardi <alessandro.suardi@gmail.com>
Subject: Re: [PATCH] ipv4: fix fib metrics
Date: Thu, 24 Mar 2011 23:27:01 +0100
Message-ID: <AANLkTinv+XGBjbFoK6vpyiDW6gBEBKFjUef+mCAMJU9i@mail.gmail.com>
References: <AANLkTik6+TrjiC6ZF+KHhZ1iPzEe2jDayr363C0HgQN4@mail.gmail.com>
	<1300980118.3747.42.camel@edumazet-laptop>
	<AANLkTikZhT5LaA-UEXniDvkneH8JScaVaCaCd4LT59cV@mail.gmail.com>
	<1300983340.3747.44.camel@edumazet-laptop>
	<1300986084.3747.101.camel@edumazet-laptop>
	<AANLkTik+Rf45wUxN86t+Zp7+AXjcJsy0vmZgvmLj-95x@mail.gmail.com>
	<1300992308.3747.205.camel@edumazet-laptop>
	<AANLkTin_gxMF1hyK_yhN+G9UGfcBKAhPE24r7tLe5j3D@mail.gmail.com>
	<1301005107.2714.113.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:58484 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756567Ab1CXW1C convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2011 18:27:02 -0400
In-Reply-To: <1301005107.2714.113.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 24, 2011 at 11:18 PM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> Le jeudi 24 mars 2011 =E0 23:11 +0100, Alessandro Suardi a =E9crit :
>
>> On a -git14 kernel + both the fib metrics and the above git diff, I
>> strace'd vpnc
>> =A0and found out this (first triplet of public IP masked intentional=
ly)
>>
>> [root@duff tmp]# egrep 'execve|garbage' strace.log |egrep '/ip|garba=
ge'
>> [pid =A04228] execve("/sbin/ip", ["/sbin/ip", "route", "get",
>> "xxx.9.13.212"], [/* 32 vars */]) =3D 0
>> [pid =A04231] execve("/sbin/ip", ["/sbin/ip", "route", "replace",
>> "10.175.0.0/19", "dev", "tun0"], [/* 32 vars */]) =3D 0
>> [pid =A04232] execve("/sbin/ip", ["/sbin/ip", "route", "flush",
>> "cache"], [/* 32 vars */]) =3D 0
>> [pid =A04234] execve("/sbin/ip", ["/sbin/ip", "route", "get",
>> "xxx.9.13.212"], [/* 32 vars */]) =3D 0
>> [pid =A04237] execve("/sbin/ip", ["/sbin/ip", "route", "add",
>> "xxx.9.13.212", "via", "192.168.1.1", "dev", "eth1", "src",
>> "192.168.1.8", "ipid", "0x043f", "advmss", "1400"], [/* 32 vars */])=
 =3D
>> 0
>> [pid =A04237] write(2, "Error: either \"to\" is duplicate,"..., 57Er=
ror:
>> either "to" is duplicate, or "ipid" is a garbage.
>>
>> 192.168.1.1 is my DSL router and 192.168.1.8 is my computer's wirele=
ss IP.
>>
>> Does this ring any bell ?
>>
>>
>
> Not a kernel error, but a tool error ?
>
>
> (ipid is only displayed by "ip ro show")
>
> grep ipid */*.c
> ip/iproute.c: =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 fpr=
intf(fp, " ipid 0x%04x", ci->rta_id);

Don't think so. This tool has been working since I built it (29 June 20=
10)
 and still works in -git2 :)

--alessandro

=A0"There's always a siren singing you to shipwreck"

=A0=A0 (Radiohead, "There There")
