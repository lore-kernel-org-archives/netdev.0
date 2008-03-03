From: Remi Denis-Courmont <rdenis@simphalempin.com>
Subject: Re: [PATCH 2/2] [IPV6]: Fix source address selection for ORCHIDaddresses
Date: Mon, 3 Mar 2008 11:19:40 +0100
Message-ID: <04ba29fb2d9e370fd968ee2906a149c1@chewa.net>
References: <20080302215954.GS5813@verkkotelakka.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: Juha-Matti Tapio <jmtapio@verkkotelakka.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:54305 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754497AbYCCKTm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Mar 2008 05:19:42 -0500
In-Reply-To: <20080302215954.GS5813@verkkotelakka.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Sun, 2 Mar 2008 23:59:54 +0200, Juha-Matti Tapio=0D
<jmtapio@verkkotelakka.net> wrote:=0D
>> Then, what you should do is to appropriately configure your policy=0D
>> (label) table via the addrlabel subsystem.=0D
> =0D
> That would propably mean doing something like merging labels 1 (::/0)=
,=0D
> 2 (6to4) and 6 (Teredo) together? I suppose that could be possible,=0D
> since after all there is also the workaround of just getting separate=
=0D
> 6to4 addresses for all the necessary interfaces.=0D
=0D
Please do NOT do this.=0D
=0D
6to4 and Teredo have separate labels for a reason: 6to4-to-6to4 is=0D
reliable, and Teredo-to-Teredo is fairly OK. 6to4-to-native often fails=
,=0D
and Teredo-to-native very often fails due to missing, congested or even=
=0D
mis-configured relays between the native IPv6 bone, and these two=0D
transition mechanism.=0D
=0D
These labels are there to try to force native-native, 6to4-6to4, IPv4-I=
Pv4,=0D
Teredo-Teredo (in that priority order) before trying mismatching pairs=0D
(native/6to4, native/Teredo, 6to4/Teredo). The Linux kernel currently h=
as=0D
this settings basically _right_. Unfortunately, glibc has the settings=0D
_wrong_ (IMHO): while it has the same labels has the kernel, the way gl=
ibc=0D
does private IPv4 addresses scoping breaks at Rule 2, which bypasses th=
e=0D
IPv6 transition mechanism labels at Rule 5. And will also break the ORC=
HID=0D
label when it is added :( That's a different story, but you may want to=
=0D
make that is not where you problems are coming from.=0D
=0D
> Moving the check to rule 0 would be ok by me. I personally prefer thi=
s=0D
> option. Configuring the labels manually requires quite a lot of=0D
> knowledge about addresses from the admin.=0D
=0D
And worst, glibc does not sync its label table with the kernel, so you =
have=0D
do replicate the settings.=0D
=0D
-- =0D
R=C3=A9mi Denis-Courmont=0D
http://www.remlab.net

