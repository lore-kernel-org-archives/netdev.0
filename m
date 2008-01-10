From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: Linux IPv6 DAD not full conform to RFC 4862 ?
Date: Thu, 10 Jan 2008 07:25:49 -0500
Message-ID: <20080110122549.GA17348@hmsreliant.think-freely.org>
References: <20080109153656.GA16962@pingi.kke.suse.de> <20080110.013857.37616214.yoshfuji@linux-ipv6.org> <20080109185744.GB25106@hmsreliant.think-freely.org> <47853825.2030002@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: YOSHIFUJI Hideaki / =?utf-8?B?5ZCJ6Jek6Iux5piO?=
	<yoshfuji@linux-ipv6.org>, kkeil@suse.de, netdev@vger.kernel.org
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:3572 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753593AbYAJM06 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jan 2008 07:26:58 -0500
Content-Disposition: inline
In-Reply-To: <47853825.2030002@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 09, 2008 at 04:09:57PM -0500, Vlad Yasevich wrote:
> Neil Horman wrote:
>> On Thu, Jan 10, 2008 at 01:38:57AM +0900, YOSHIFUJI Hideaki / =E5=90=
=89=E8=97=A4=E8=8B=B1=E6=98=8E wrote:
>>> In article <20080109153656.GA16962@pingi.kke.suse.de> (at Wed, 9 Ja=
n 2008 16:36:56 +0100), Karsten Keil <kkeil@suse.de> says:
>>>
>>>> So I think we should disable the interface now, if DAD fails on a
>>>> hardware based LLA.
>>> I don't want to do this, at least, unconditionally.
>>>
>>> Options (not exclusive):
>>>
>>> - we could have "dad_reaction" interface variable and
>>>  > 1: disable interface
>>>  =3D 1: disable IPv6
>>>  < 0: ignore (as we do now)
>>>
>> I like the flexibility of this solution, but given that the only par=
t of the RFC
>> that we're missing on at the moment is that we SHOULD disable the in=
terface on
>> DAD failure for a link-local address, I would think this scheme woul=
d be good:
>>
>>   < 0 : ignore, and del address from interface (current behavior)   =
=3D 0 :=20
>> disable interface for dad failure for a link-local address   > 0 : d=
isable=20
>> interface for dad failure for any address=20
>> Regards
>> Neil
>> =20
>
> Just a friendly reminder that such a scheme should only be
> applied to autoconfigured addresses.  A manually configured
> duplicated address should not bring down the whole interface.
>

I agree, but I think that case would be covered by the default option a=
bove
(sysctl < 0).

Neil

> -vlad
