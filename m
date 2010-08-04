From: Yegor Yefremov <yegorslists@googlemail.com>
Subject: Re: KS8695: possible NAPI issue
Date: Wed, 4 Aug 2010 16:40:09 +0200
Message-ID: <AANLkTimiTiF4mbV-aeOymHEn4BhY743UcHfCcVYim3Ec@mail.gmail.com>
References: <f69abfc31003020404y7af77fe5icefeee4644c7d08e@mail.gmail.com>
	<f69abfc31003040210i7e8a136am4b4a97306ba770cf@mail.gmail.com>
	<c6ed1ac51003042254g27f65f9dhd9bd731e05a9518@mail.gmail.com>
	<f69abfc31003050206h4f9ffe65s2b90e6acea014ec2@mail.gmail.com>
	<1267798077.2576.17.camel@myhost>
	<f69abfc31003050700y57718a6aje3c1ff41d04748ae@mail.gmail.com>
	<c6ed1ac51003080104l4d67d72aybd3909ac12b54e3b@mail.gmail.com>
	<f69abfc31003080610m2701309ekd1a4a38ac2685703@mail.gmail.com>
	<f69abfc31003080611xde6fe26v150dd1fa90b82928@mail.gmail.com>
	<c6ed1ac51003081750v19f9d5fuf07ad0cc2478005d@mail.gmail.com>
	<f69abfc31003150219u4e103b0fg3dc22628054e4327@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dick Hollenbeck <dick@softplc.com>, netdev@vger.kernel.org,
	zealcook@gmail.com
To: figo zhang <figo1802@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:52786 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932068Ab0HDOkU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Aug 2010 10:40:20 -0400
Received: by bwz1 with SMTP id 1so2428690bwz.19
        for <netdev@vger.kernel.org>; Wed, 04 Aug 2010 07:40:19 -0700 (PDT)
In-Reply-To: <f69abfc31003150219u4e103b0fg3dc22628054e4327@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 15, 2010 at 11:19 AM, Yegor Yefremov
<yegorslists@googlemail.com> wrote:
> On Tue, Mar 9, 2010 at 2:50 AM, figo zhang <figo1802@gmail.com> wrote=
:
>> 2010/3/8 Yegor Yefremov <yegorslists@googlemail.com>:
>>> This is ping afterwards:
>>>
>>> debian:~# ping -c 1 192.168.1.38
>>>
>>> PING 192.168.1.38 (192.168.1.38) 56(84) bytes of data.
>>>
>>>
>>> =C2=A0tx =C2=A0 ram addr =3D c371c202 , data len =3D 62
>>>
>>> =C2=A0dst:00:18:f3:fe:84:84 src:00:04:d9:80:94:cd type: 0x0800
>>
>> =3D> the print info is not clear, it had better just keep "print_mem=
()",
>> and remove other printk.
>>
>>>
>>> =C2=A00xc371c20e : 45 00
>>>
>>> =C2=A00xc371c212 : 00 54 00 00 40 00 40 01 b6 f0 c0 a8 01 42 c0 a8
>>>
>>> =C2=A00xc371c222 : 01 26 08 00 65 51 1a 07 00 01 92 00 95 4b 5f 57
>>>
>>> =C2=A00xc371c232 : 07 00 08 09 0a 0b 0c 0d 0e 0f 10 11 12 13 14 15
>>>
>>> =C2=A00xc371c242 : 16 17 18 19 1a 1b 1c 1d 1e 1f 20 21 22 23 24 25
>>>
>>> =C2=A00xc371c252 : 26 27 28 29 2a 2b 2c 2d 2e 2f 30 31 32 33 34 35
>>>
>>> =C2=A00xc371c262 : 36 37
>>>
>>>
>>>
>>> =C2=A0tx =C2=A0 ram addr =3D c371c202 , data len =3D 2a
>>>
>>> =C2=A0dst:00:18:f3:fe:84:84 src:00:04:d9:80:94:cd type: 0x0806
>>>
>>> =C2=A00xc371c20e : 00 01
>>>
>>> =C2=A00xc371c212 : 08 00 06 04 00 01 00 04 d9 80 94 cd c0 a8 01 42
>> =3D> it is a send arp packet, "c0 a8 01 42" is your curr ip addr
>> 192.168.1.66, tell the other side it's ip addr.
>>>
>>> =C2=A00xc371c222 : 00 00 00 00 00 00 c0 a8 01 26
>>>
>>>
>>>
>>> =C2=A0rx =C2=A0 ram addr =3D c35d2020 , data len =3D 3c
>>>
>>> =C2=A0dst:00:04:d9:80:94:cd src:00:18:f3:fe:84:84 type: 0x0806
>>>
>>> =C2=A00xc35d202c : 00 01
>>>
>>> =C2=A00xc35d2030 : 08 00 06 04 00 02 00 18 f3 fe 84 84 c0 a8 01 26
>>
>> =3D> it is a reply arp packet, "c0 a8 01 26" (192.168.1.38 ) is othe=
r
>> side ip addr. so the arp
>> request is finished.
>>
>>>
>>> =C2=A00xc35d2040 : 00 04 d9 80 94 cd c0 a8 01 42 00 00 00 00 00 00
>>>
>>> =C2=A00xc35d2050 : 00 00 00 00 00 00 00 00 00 00 00 00
>>>
>> =3D> so , it should still send =C2=A0"IMCP" packet, you using "ping =
-c 1", it
>> send one IMCP packet , and wait for reply. =C2=A0at this point, it h=
ave not
>> send packet?
>
> I made some tests on Fr with a Netbook connected directly to our
> ks8695 based device and not to the companies network. During the test
> I couldn't encounter any problem. Than I connected ks8695 again to th=
e
> companies network and the issue was there right away. So I decided to
> check how many broadcast I get and it turned out that I have one
> device on the network that is sending broadcast almost every second i=
f
> not more frequent. It turned out that the network on ks8695 was not
> completely down, but very slow and many packets got lost. As soon as =
I
> removed the broadcast sending device I could ping ks8695. The
> consequences:
>
> 1. as long as I make no netcat transfer, the network responses are as
> usual regardless of many broadcasts
> 2. if during netcat a broadcast occurs, than the network is getting
> slow, so that if during a constant ping you get a broadcast that ping
> response gets lost
>
> Any idea how broadcast during transfer could affect NAPI in that way?

Tried 2.6.35. Have still the same problems. Another observation:

if I add eth0 to a bridge (br0), then I have no problems. So ks8695
network driver is still involved, but the upper level seems to make
the difference.

Any idea?

Regards,
Yegor
