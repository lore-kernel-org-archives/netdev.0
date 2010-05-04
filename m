From: enh <enh@google.com>
Subject: Re: linux kernel's IPV6_MULTICAST_HOPS default is 64; should be 1?
Date: Mon, 3 May 2010 23:27:23 -0700
Message-ID: <AANLkTimf-FWCsiLqYDGg4nl-relRMuNvDowfTKZbe9kx@mail.gmail.com>
References: <4BDF8387.4000303@hp.com>
	 <20100503.230553.200626786.davem@davemloft.net>
	 <AANLkTingTdmhyJhENb9AYDjUT7m_-yQflw5-gJqIA9iw@mail.gmail.com>
	 <20100503.232249.200767273.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: brian.haley@hp.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:9195 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755220Ab0EDG11 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 May 2010 02:27:27 -0400
Received: from hpaq5.eem.corp.google.com (hpaq5.eem.corp.google.com [10.3.21.5])
	by smtp-out.google.com with ESMTP id o446RPm4023552
	for <netdev@vger.kernel.org>; Mon, 3 May 2010 23:27:25 -0700
Received: from yxe14 (yxe14.prod.google.com [10.190.2.14])
	by hpaq5.eem.corp.google.com with ESMTP id o446RNLt010885
	for <netdev@vger.kernel.org>; Mon, 3 May 2010 23:27:24 -0700
Received: by yxe14 with SMTP id 14so1068663yxe.5
        for <netdev@vger.kernel.org>; Mon, 03 May 2010 23:27:23 -0700 (PDT)
In-Reply-To: <20100503.232249.200767273.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 3, 2010 at 23:22, David Miller <davem@davemloft.net> wrote:
> From: enh <enh@google.com>
> Date: Mon, 3 May 2010 23:19:22 -0700
>
>> for the *unicast* hops, a part of the RFC i didn't quote says:
>>
>> =C2=A0 =C2=A0If the [IPV6_UNICAST_HOPS] option is not set, the
>> =C2=A0 =C2=A0system selects a default value.
>>
>> but for the *multicast* hops, which is what i'm talking about, this
>> part of the quoted text seems pretty definitive:
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0If IPV6_MULTICAST_HOPS is n=
ot set, the default is 1
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0(same as IPv4 today)
>>
>> this is what my test shows isn't true of linux; linux reuses its
>> unicast default instead.
>
> Ok, I see, so yeah this needs to be fixed to use "1" instead of
> "-1" in the np->xxx ipv6 socket initialization.

i think so. there's already the IPV6_DEFAULT_MCASTHOPS constant
defined to 1 but unused according to gitweb, so you might want to
either use it or remove it.

thanks!

--=20
Elliott Hughes - http://who/enh - http://jessies.org/~enh/
