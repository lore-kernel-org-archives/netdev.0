From: =?ISO-8859-1?Q?Ra=FAl_Hern=E1ndez?= <rauhersu@gmail.com>
Subject: Re: high rate injection and fragmentation
Date: Mon, 9 Feb 2009 18:18:50 +0100
Message-ID: <3f847c820902090918j4da4b94o3eee35415f088afb@mail.gmail.com>
References: <3f847c820902090720w98e2ca8pc66f55716c030194@mail.gmail.com>
	 <Pine.LNX.4.64.0902091806510.31742@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f161.google.com ([209.85.218.161]:41970 "EHLO
	mail-bw0-f161.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753185AbZBIRSw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2009 12:18:52 -0500
Received: by bwz5 with SMTP id 5so1581721bwz.13
        for <netdev@vger.kernel.org>; Mon, 09 Feb 2009 09:18:50 -0800 (PST)
In-Reply-To: <Pine.LNX.4.64.0902091806510.31742@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ilpo,

Thanks for your answer, I did not know about that feature. Looking at
my settings:

# ethtool -k eth2
=2E..
tcp segmentation offload: on

I think ethereal hooks up before reaching the TCP offload which is
handled by the NIC.

Best regards,
Raul

On Mon, Feb 9, 2009 at 5:09 PM, Ilpo J=E4rvinen <ilpo.jarvinen@helsinki=
=2Efi> wrote:
> On Mon, 9 Feb 2009, Ra=FAl Hern=E1ndez wrote:
>
>> I am trying to understand the behavior of the IP stack regarding
>> fragmentation when injecting at high speed ratio : so far I am seein=
g
>> that TCP starts multiplexing the application level protocol (in my
>> case, diameter: previously 1 diameter message =3D 1 TCP message, whe=
n
>> the rate increases, multiple diameter messages are coalesced in one
>> TCP messages - similar to a Nagle control -).
>>
>> At that very moment is when we start finding issues regarding packet
>> length checking with ethereal: frames start growing due the multiple=
x
>> above and ethereal shows captured packets >3000 bytes ! (IP total
>> lenght makes sense as well according to that figure). The thing is
>> that I am working under ethernet law (1500 bytes) and I have checked
>> through iproute this is the MTU set for the link (neither
>> DONT_FRAGMENT ip options for the socket regarding nor MTU
>> modifications have been introduced) so my understanding is that no
>> packet > 1500 bytes should be allowed with my configuration (would
>> need fragmentation).
>>
>> Checking the IP header with ethereal, "dont fragment" is set and
>> "fragment offset"=3D0. IOW, It seems that IP is not fragmenting the
>> packet although > MTU which I am not able to understand.
>>
>> Any idea why Linux tries to work with MTU > 1500 bytes when not
>> configured explicitly to do so (may I have missed more
>> options/checkings) ? Hope not to be cheated by Ethereal ...
>
> I suppose you refer here to what GSO is doing though the explanation
> is so fuzzy that I lost track of it in the middle. ...You needs
> ethtool to configure it.
>
> --
>  i.



--=20
Los viajes son en la juventud una parte de educaci=F3n y, en la vejez,
una parte de experiencia -- Francis Bacon
