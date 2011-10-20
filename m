From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: [PATCH] net: change capability used by socket options IP{,V6}_TRANSPARENT
Date: Wed, 19 Oct 2011 20:32:31 -0700
Message-ID: <CANP3RGf1ZyNEiADXMsD1C=4GMyOMvxEZQ93nYpghhXhCJKNF6Q@mail.gmail.com>
References: <20110920.154213.888729603269720228.davem@redhat.com>
	<1318889783-23183-1-git-send-email-zenczykowski@gmail.com>
	<20111019.193435.1214580639401316303.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bazsi@balabit.hu
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:26715 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751864Ab1JTDcf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2011 23:32:35 -0400
Received: from hpaq6.eem.corp.google.com (hpaq6.eem.corp.google.com [172.25.149.6])
	by smtp-out.google.com with ESMTP id p9K3WX9h014054
	for <netdev@vger.kernel.org>; Wed, 19 Oct 2011 20:32:33 -0700
Received: from iaqq3 (iaqq3.prod.google.com [10.12.43.3])
	by hpaq6.eem.corp.google.com with ESMTP id p9K3VZNb021357
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 19 Oct 2011 20:32:32 -0700
Received: by iaqq3 with SMTP id q3so4905257iaq.10
        for <netdev@vger.kernel.org>; Wed, 19 Oct 2011 20:32:32 -0700 (PDT)
In-Reply-To: <20111019.193435.1214580639401316303.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Are you okay with the patch without any warnings or deprecation marking=
s?
Or are you against opening up CAP_NET_RAW to this in general?

On Wed, Oct 19, 2011 at 4:34 PM, David Miller <davem@davemloft.net> wro=
te:
> From: Maciej =C5=BBenczykowski <zenczykowski@gmail.com>
> Date: Mon, 17 Oct 2011 15:16:23 -0700
>
>> From: Maciej =C5=BBenczykowski <maze@google.com>
>>
>> Up till now the IP{,V6}_TRANSPARENT socket options (which actually s=
et
>> the same bit in the socket struct) have required CAP_NET_ADMIN
>> privileges to set or clear the option.
>>
>> - we make clearing the bit not require any privileges.
>> - we deprecate using CAP_NET_ADMIN for this purpose.
>> - we allow CAP_NET_RAW to set this bit, because raw
>> =C2=A0 sockets already effectively allow you to emulate socket
>> =C2=A0 transparency.
>> - we print a warning (but allow it) if you try to set the socket
>> =C2=A0 option with CAP_NET_ADMIN privs, but without CAP_NET_RAW.
>>
>> Signed-off-by: Maciej =C5=BBenczykowski <maze@google.com>
>
> Warnings for something that has worked ever since the feature was
> added, and in fact was the only way to make use of the feature, is
> terrible.
>
> You must support the status quo forever or else you risk breaking
> existing setups. =C2=A0So the warning is pointless, you'll never be
> able to remove CAP_NET_ADMIN from these code paths, so there is
> zero value in warning about it because we'll never change this.
>
> I'm disliking these changes more and more. =C2=A0I refuse to apply th=
is
> patch.
>



--=20
Maciej A. =C5=BBenczykowski
Kernel Networking Developer @ Google
1600 Amphitheatre Parkway, Mountain View, CA 94043
tel: +1 (650) 253-0062
