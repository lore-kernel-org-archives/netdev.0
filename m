From: Christophe Jelger <Christophe.Jelger@unibas.ch>
Subject: Re: Virtual device and ARP table
Date: Mon, 07 Jun 2010 15:03:58 +0200
Message-ID: <4C0CEE3E.50100@unibas.ch>
References: <4C0CC810.7030501@unibas.ch> <1275913320.2545.53.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2pub.unibas.ch ([131.152.227.82]:39538 "EHLO
	smtp2pub.unibas.ch" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754595Ab0FGNN4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jun 2010 09:13:56 -0400
In-Reply-To: <1275913320.2545.53.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Le lundi 07 juin 2010 =E0 12:21 +0200, Christophe Jelger a =E9crit :
>> Hello,
>>
>> I am currently "resurrecting" a Linux module (called LUNAR) which I=20
>> co-developed in 2007 and I'm having a weird kernel crash. This code=20
>> basically used to work fine up to 2.6.18 which was the latest versio=
n=20
>> before we stopped our development. I quickly ported it to 2.6.{31,32=
}:=20
>> it compiles fine and loads fine, but it crashes/hangs the kernel whe=
n=20
>> it's really being used.
>>
>> The module is a virtual device used for MANET routing: with the curr=
ent=20
>> version, it basically "captures" DNS requests sent to the virtual=20
>> interface --> this triggers the sending of a fake DNS reply (see bel=
ow)=20
>> and the creation of an ARP table entry for the destination (the MANE=
T=20
>> route is built at the same time). Packets can then be sent to the=20
>> destination.
>>
>> The problem I'm having is that the kernel quickly hangs after I crea=
te a=20
>> new ARP entry (actually only if it's being used). If the entry I cre=
ate=20
>> is set to NUD_PERMANENT, then everything works fine! I use=20
>> __neigh_lookup_errno to lookup/create the entry and neigh_lookup to=20
>> set/update the MAC address. Note that the ARP entry is created witho=
ut=20
>> problem, but typically even just doing a userspace "arp -a" command =
can=20
>> crash the kernel (it also hangs the userspace command!). Doing "arp =
-na"=20
>> usually does NOT crash the kernel!
>>
>> I guess the problem comes from a combination of ARP + DNS=20
>> lookups/replies. Note that my kernel module has its own internal fak=
e=20
>> DNS server which captures lookups and sends replies directly back to=
 the=20
>> stack. What is amazing: if the ARP entry I create is set to=20
>> NUD_PERMANENT, then I don't get any crash (however I cannot develop =
my=20
>> module with permanent ARP entries).
>>
>> I'm wondering if there were any major changes to the neighbor and ar=
p=20
>> code (between 2.6.18 and 2.6.31) that are somehow causing this probl=
em ?...
>>
>> Any hint is very welcome.
>>
>> thanks in advance,
>> Christophe
>>
>> PS: I can easily reproduce the problem, and was trying to debug with=
=20
>> qemu and gdb server but so fra no success to clearly identify the=20
>> problem. Last point: it seems the kernel does not really "crash" but=
=20
>> rather ends up in some unstable state and maybe in a loop.
>> --
>=20
> Hi Christophe
>=20
> You should ask these kind of questions on netdev instead of lkml.
>=20
> And of course, post your patch, or send us a crystal ball ;)
>=20
> Yes, many things changed between 2.6.18 and 2.6.34
>=20

Eric: thanks for the forward to the netdev list. Regarding the code, I=20
of course welcome any help but didn't want to pollute the list with=20
unsollicited code: I can of course of course send it directly to anyone=
=20
who is willing to help (I can easily reproduce the problem on different=
=20
machines).

Christophe



