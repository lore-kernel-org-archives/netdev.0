From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [RFC] ipv6: use a random ifid for headerless devices
Date: Mon, 30 Nov 2015 14:55:30 +0100
Message-ID: <87r3j74mnh.fsf@nemi.mork.no>
References: <1448884508-5235-1-git-send-email-bjorn@mork.no>
	<CAPA1RqB8uc3vTOi4HXMdU3LREvmcKnUk=ygf3aax1kVZ+wcwJw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: network dev <netdev@vger.kernel.org>
To: =?utf-8?B?5ZCJ6Jek6Iux5piO?= <hideaki.yoshifuji@miraclelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:37195 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753943AbbK3Nzl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2015 08:55:41 -0500
In-Reply-To: <CAPA1RqB8uc3vTOi4HXMdU3LREvmcKnUk=ygf3aax1kVZ+wcwJw@mail.gmail.com>
	(=?utf-8?B?IuWQieiXpOiLseaYjiIncw==?= message of "Mon, 30 Nov 2015 21:01:32
 +0900")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E <hideaki.yoshifuji@miraclelinux.co=
m> writes:

>>> +static int addrconf_ifid_random(u8 *eui, struct net_device *dev)
>> +{
>> +       get_random_bytes(eui, 8);
>> +       eui[0] |=3D 0x02;
>> +       return 0;
>> +}
>> +
>
> Since random identifier is locally assigned, drop the global bit
> instead if setting it.

Yes, definitely. Thanks.  I'm considering reusing __ipv6_regen_rndid()
which already does this correctly, and also avoids some locally assigne=
d
addresses with special meanings.

Another issue with the initial RFC is that every prefix will have a new
random ifid, which isn't necessarily what the users expect.  I wonder i=
f
it would be acceptable to abuse the rndid field for storing a "permanen=
t"
random ifid?


Bj=C3=B8rn
