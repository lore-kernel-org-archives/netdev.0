From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH v3 02/16] e100: Support RXFCS feature flag.
Date: Sat, 11 Feb 2012 08:21:48 -0800
Message-ID: <4F36959C.50902@candelatech.com>
References: <1328922274-23993-1-git-send-email-greearb@candelatech.com> <1328922274-23993-3-git-send-email-greearb@candelatech.com> <CAHXqBFJHoFd5W+YRn9bVg6RsqjFsTdaEM-MMdQjSwVVSckwS=A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:56403 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751956Ab2BKQVu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Feb 2012 11:21:50 -0500
In-Reply-To: <CAHXqBFJHoFd5W+YRn9bVg6RsqjFsTdaEM-MMdQjSwVVSckwS=A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/11/2012 08:07 AM, Micha=C5=82 Miros=C5=82aw wrote:
> 2012/2/11<greearb@candelatech.com>:
>> From: Ben Greear<greearb@candelatech.com>
> [...]
>> @@ -1951,9 +1956,11 @@ static int e100_rx_indicate(struct nic *nic, =
struct rx *rx,
>>         }
>>
>>         /* Get actual data size */
>> +       if (unlikely(dev->features&  NETIF_F_RXFCS))
>> +               fcs_pad =3D 4;
>>         actual_size =3D le16_to_cpu(rfd->actual_size)&  0x3FFF;
>> -       if (unlikely(actual_size>  RFD_BUF_LEN - sizeof(struct rfd))=
)
>> -               actual_size =3D RFD_BUF_LEN - sizeof(struct rfd);
>> +       if (unlikely(actual_size>  RFD_BUF_LEN + fcs_pad - sizeof(st=
ruct rfd)))
>> +               actual_size =3D RFD_BUF_LEN + fcs_pad - sizeof(struc=
t rfd);
>
> BTW, Is this even triggered? I looks like this would indicate
> corruption in the descriptor.

No idea, but better safe than sorry unless someone can prove it never h=
appens
in all cases...

Ben

--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
