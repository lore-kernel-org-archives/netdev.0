From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: Linux IPv6 DAD not full conform to RFC 4862 ?
Date: Wed, 09 Jan 2008 16:09:57 -0500
Message-ID: <47853825.2030002@hp.com>
References: <20080109153656.GA16962@pingi.kke.suse.de> <20080110.013857.37616214.yoshfuji@linux-ipv6.org> <20080109185744.GB25106@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
	<yoshfuji@linux-ipv6.org>, kkeil@suse.de, netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:32568 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752301AbYAIVJ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2008 16:09:59 -0500
In-Reply-To: <20080109185744.GB25106@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Neil Horman wrote:
> On Thu, Jan 10, 2008 at 01:38:57AM +0900, YOSHIFUJI Hideaki / =E5=90=89=
=E8=97=A4=E8=8B=B1=E6=98=8E wrote:
>> In article <20080109153656.GA16962@pingi.kke.suse.de> (at Wed, 9 Jan=
 2008 16:36:56 +0100), Karsten Keil <kkeil@suse.de> says:
>>
>>> So I think we should disable the interface now, if DAD fails on a
>>> hardware based LLA.
>> I don't want to do this, at least, unconditionally.
>>
>> Options (not exclusive):
>>
>> - we could have "dad_reaction" interface variable and
>>  > 1: disable interface
>>  =3D 1: disable IPv6
>>  < 0: ignore (as we do now)
>>
> I like the flexibility of this solution, but given that the only part=
 of the RFC
> that we're missing on at the moment is that we SHOULD disable the int=
erface on
> DAD failure for a link-local address, I would think this scheme would=
 be good:
>=20
>   < 0 : ignore, and del address from interface (current behavior)=20
>   =3D 0 : disable interface for dad failure for a link-local address=20
>   > 0 : disable interface for dad failure for any address=20
>=20
> Regards
> Neil
> =20

Just a friendly reminder that such a scheme should only be
applied to autoconfigured addresses.  A manually configured
duplicated address should not bring down the whole interface.

-vlad
