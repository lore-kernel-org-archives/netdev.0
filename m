From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] macvlan: lockless tx path
Date: Wed, 10 Nov 2010 15:46:04 -0800
Message-ID: <4CDB2EBC.2090905@candelatech.com>
References: <1289403709.2860.216.camel@edumazet-laptop>	 <4CDAD8C8.20807@candelatech.com>	 <1289411027.2860.248.camel@edumazet-laptop>	 <4CDADC17.6070506@candelatech.com>	 <1289413120.2469.12.camel@edumazet-laptop>	 <4CDAE713.7020309@candelatech.com>	 <1289421187.2469.127.camel@edumazet-laptop> <4CDB1021.507@candelatech.com>	 <1289427705.17691.52.camel@edumazet-laptop>	 <4CDB226A.8080903@candelatech.com> <1289432184.17691.141.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:41297 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757322Ab0KJXqG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Nov 2010 18:46:06 -0500
In-Reply-To: <1289432184.17691.141.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/10/2010 03:36 PM, Eric Dumazet wrote:
> Le mercredi 10 novembre 2010 =C3=A0 14:53 -0800, Ben Greear a =C3=A9c=
rit :
>
>> I did similar, and then wrote extra code to detect a 64-bit kernel a=
nd if
>> so assume that the counters wrap at 64 bits so I didn't have to poll=
 so
>> often to make sure I didn't miss a wrap for a 10G NIC.  If instead o=
ne wraps at 33
>> bits and the other at 36, there is no way for me to deal with the wr=
ap
>> properly w/out explicitly knowing about that 33 and 36.
>>
>
> How do you define 'wrap around' ? Maybe your definition is wrong.

Maybe so.  My algorithm looks like:

  // uint64 accum;
  // uint32 old;
  // uint32 new;
  if (old > new) {
      // This assumes counters wrap at 32 bits (ie, 0xFFFFFFFF).
      accum +=3D ((uint32)(0xFFFFFFFF) - old) + new;
  }
  else if (old < new) {
      accum +=3D new - old;
  }
  old =3D new;

=2E..

Is there some way I can do this w/out the (0xFFFFFFFF - old),
and thus the assumption of 32-bit counters?

Thanks,
Ben

--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

