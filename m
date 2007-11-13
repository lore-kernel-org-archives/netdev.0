From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Problem with frame time stamping
Date: Tue, 13 Nov 2007 11:36:37 +0100
Message-ID: <47397E35.6080203@cosmosbay.com>
References: <2cbbd8de0711120742h35f27441p5f096e5e99e1d7dc@mail.gmail.com>	 <20071112174759.c2777ea2.dada1@cosmosbay.com> <2cbbd8de0711130207t82f2f46h9ee1b876a61bad6a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-net@vger.kernel.org,
	netfilter-devel@vger.kernel.org, patrik.arlos@bth.se
To: Antoine Zen-Ruffinen <antoine.zen@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <2cbbd8de0711130207t82f2f46h9ee1b876a61bad6a@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Antoine Zen-Ruffinen a =E9crit :
> What does it bring me to have a nanosecond precision if it is not
> related to the actual arrival of frame time ? As it seem I can feel
> skb->tstamp with whatever I want, I always become something else usin=
g
> ioctl(). (I'm using kernel 2.6.23).
>
> 2007/11/12, Eric Dumazet <dada1@cosmosbay.com>:
>  =20
>> On Mon, 12 Nov 2007 16:42:34 +0100
>> "Antoine Zen-Ruffinen" <antoine.zen@gmail.com> wrote:
>>
>>    =20
>>> Dear all,
>>>
>>> I'm writing a network analyzer software using Linux and I need a VE=
RY
>>> precise frame time stamping. Therefor I am planing to add my own ti=
me
>>> stamping algorithm on a modified network driver. For test purpose I
>>> did so :
>>>
>>>       skb->tstamp.tv64 =3D 0x00010002;
>>>       netif_rx(skb);
>>>
>>> On the user side, I ask for the timestamp that way :
>>>
>>>       ...
>>>       sock =3D socket(AF_PACKET, SOCK_RAW, type);
>>>       ...
>>>       //bind this socket with the interface using my modified drive=
r.
>>>       ...
>>>       recvByteCount =3D recv(sock, buffer, 1514, 0);
>>>       ioctl(sock, SIOCGSTAMP, &timeStamp);
>>>
>>> I was surprised to see that the var timeStamp was still holding a
>>> count of second since  year 1970.
>>>      =20
But then, maybe your problem comes from your code : timeStamp should be=
=20
declared as "struct timeval" of course, to get both tv_sec and tv_usec.

struct timeval tv;
ioctl(sock, SIOCSTAMP, &tv);
printf("packet arrived at %ld.%06ld\n", (long)tv.tv_sec, (long)tv.tv_us=
ec);


If you *want* nanosecond resolution instead of microsecond, use :

struct timespec ts;
ioctl(sock, SIOCSTAMPNS, &ts);
printf("packet arrived at %ld.%09ld\n", (long)ts.tv_sec, (long)ts.tv_ns=
ec);




-
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
