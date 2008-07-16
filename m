From: "Holger Hoffstaette" <holger@wizards.de>
Subject: Re: sendfile() broken with 2.6.26 + Apache 2 ?
Date: Wed, 16 Jul 2008 16:58:08 +0200
Message-ID: <pan.2008.07.16.14.58.05.879125@wizards.de>
References: <487CD7A7.2080800@jeffray.co.uk> <487D893A.5080207@cosmosbay.com> <487DA388.3030104@jeffray.co.uk> <487DBA74.3090800@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:47696 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759938AbYGPO6U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jul 2008 10:58:20 -0400
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1KJ8SN-0004fy-Ot
	for netdev@vger.kernel.org; Wed, 16 Jul 2008 14:58:15 +0000
Received: from port-87-234-135-63.dynamic.qsc.de ([87.234.135.63])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 16 Jul 2008 14:58:15 +0000
Received: from holger by port-87-234-135-63.dynamic.qsc.de with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 16 Jul 2008 14:58:15 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 16 Jul 2008 11:08:04 +0200, Eric Dumazet wrote:

> Ian Jeffray a =E9crit :
>> Hi Eric,
>>=20
>> Thanks for directing me to a better list.
>>=20
>> Further responses below:
>>=20
>> Eric Dumazet wrote:
>>> CC to netdev where this report might find better answers
>>>
>>> Ian Jeffray a =E9crit :
>>>> All,
>>>>
>>>> I moved from kernel 2.6.25.4 to 2.6.26 yesterday and observed that
>>>> large files sent via Apache2 are partially corrupt.
>>>>
>>>> This appears to be linked to sendfile() -- disabling the use of
>>>> sendfile in the apache config (EnableSendfile Off) allows it to
>>>> function as normal.
>>>>
>>>> My system is a simple Core2Duo running Debian lenny/sid; nothing
>>>> special, and I have never observed problems like this before.
>>>>
>>>> The problem feels certainly related to sendfile() since the data r=
eads
>>>> correctly from disc in other programs, and via CIFS etc.
>>>>
>>>> The corruption happens part-way in to the file... I've no exact fi=
gure
>>>> but it would seem like maybe 32KB -- I'm seeing broken PNGs served
>>>> from Apache, where the top few dozen lines decode correctly, and t=
he
>>>> rest is garbage.
>>>>
>>>> I've made basically no configuration changes between 2.6.25.4 and
>>>> 2.6.26 and have explicitly tried both enabling and disabling the n=
ew
>>>> PAT support to no effect.
>>>>
>>>> This is completely repeatable and reproducible.
>>>>
>>>> Is anyone else seeing this broken behaviour?
>>>>
>>>>
>>>
>>> What kind of network adapter are you using ? (lspci | grep -i ether=
)
>>=20
>> 02:00.0 Ethernet controller: Attansic Technology Corp. L1 Gigabit
>> Ethernet Adapter (rev b0)
>>=20
>>=20
>>> If you disable TCP segmentation offload on this NIC (ethtool -K eth=
0
>>> tso off) , is this problem still present ?
>>=20
>> Wow.  That 'solves' the problem!  Great.
>>=20
>> Does this therefore point to an attansic driver issue?
>=20
> Yes, maybe related to commit 9d90fb1ac9d97da86e24d9ea947bf2a2f333829a
>=20
> In this patch, Jay Cliburn enabled TSO by default for atl1 driver.
>=20
> This might be a driver problem, or a generic sendfile() problem, I do=
nt
> know...

Maybe related to http://lkml.org/lkml/2007/12/6/229 ?
I switched to a different server with e1000 NIC in the meantime and so =
I
cannot test if this is still a problem in 2.6.26, but apparently it see=
ms
so. For me the combo e1000/e1000e + sendfile works reliably..

Holger


