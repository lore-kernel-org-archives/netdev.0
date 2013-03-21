From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next] gro: relax ID check in inet_gro_receive()
Date: Thu, 21 Mar 2013 14:37:38 -0700
Message-ID: <CAEP_g=8pqnVddN1jjZNVQ-POc3ths5DmAnr-9=UYKSpgFGrysQ@mail.gmail.com>
References: <CANP3RGc1+n3Qt7k53NJtPO9njZw+WNVLKTLJq=ErYJmyb-Skcg@mail.gmail.com>
 <20130321.162017.605403865098695084.davem@davemloft.net> <CANP3RGdjmgm10rH4AZAVt8Zx+MjwKkzxZ6hoJYuYmQXEz25qQg@mail.gmail.com>
 <20130321.170511.612698812448620739.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: maze@google.com, dkravkov@gmail.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, dmitry@broadcom.com, eilong@broadcom.com,
	pshelar@nicira.com, hkchu@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog126.obsmtp.com ([74.125.149.155]:40544 "HELO
	na3sys009aog126.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753353Ab3CUVh7 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Mar 2013 17:37:59 -0400
Received: by mail-ie0-f198.google.com with SMTP id 17so17896466iea.1
        for <netdev@vger.kernel.org>; Thu, 21 Mar 2013 14:37:58 -0700 (PDT)
In-Reply-To: <20130321.170511.612698812448620739.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 21, 2013 at 2:05 PM, David Miller <davem@davemloft.net> wro=
te:
> From: Maciej =C5=BBenczykowski <maze@google.com>
> Date: Thu, 21 Mar 2013 13:47:07 -0700
>
>> They might create non incrementing IP ID packet sequences on the wir=
e,
>> and this may prevent GRO from kicking in, but it does not make TSO
>> non-reversible
>> (if anything it makes it easy to detect that it happened).
>
> This is not an acceptable outcome for any form GSO, it should be
> completely transparent.  The packets we would have output individuall=
y
> and those which result from the segmented frame must be
> indistinguishable.

We actually don't set the outer IP ID for GRE packets with the DF bit
set in the non-GSO/TSO case either (and this is not new behavior).
Obviously TCP/IP header compression doesn't apply to the GRE packet
itself.

Therefore, I think if the driver is switched to increment the inner
ID, which it sounds like it can be, then everything should be
transparent.
