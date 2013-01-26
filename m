From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH 2/5] soreuseport: TCP/IPv4 implementation
Date: Fri, 25 Jan 2013 19:40:10 -0800
Message-ID: <CA+mtBx-pF=guzDH-eHtDJ213ettKoiJFm6G_vSoW0k3146a=Fw@mail.gmail.com>
References: <alpine.DEB.2.00.1301221141310.26417@pokey.mtv.corp.google.com>
	<20130125080811.GM9147@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	netdev@markandruth.co.uk, eric.dumazet@gmail.com
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:62655 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754740Ab3AZDkK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jan 2013 22:40:10 -0500
Received: by mail-ie0-f176.google.com with SMTP id 13so261911iea.21
        for <netdev@vger.kernel.org>; Fri, 25 Jan 2013 19:40:10 -0800 (PST)
In-Reply-To: <20130125080811.GM9147@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Steffen.  I'm looking at it.

Tom

On Fri, Jan 25, 2013 at 12:08 AM, Steffen Klassert
<steffen.klassert@secunet.com> wrote:
> On Tue, Jan 22, 2013 at 11:50:24AM -0800, Tom Herbert wrote:
>> -     } else if (tb->fastreuse &&
>> -                (!sk->sk_reuse || sk->sk_state =3D=3D TCP_LISTEN))
>> -             tb->fastreuse =3D 0;
>> +             if (sk->sk_reuseport) {
>> +                     tb->fastreuseport =3D 1;
>> +                     tb->fastuid =3D uid;
>> +             } else {
>> +                     tb->fastreuseport =3D 0;
>> +                     tb->fastuid =3D 0;
>> +             }
>> +     } else {
>> +             if (tb->fastreuse &&
>> +                 (!sk->sk_reuse || sk->sk_state =3D=3D TCP_LISTEN))
>> +                     tb->fastreuse =3D 0;
>> +             if (tb->fastreuseport &&
>> +                 (!sk->sk_reuseport || !uid_eq(tb->fastuid, uid))) =
{
>> +                     tb->fastreuseport =3D 0;
>> +                     tb->fastuid =3D 0;
>> +             }
>
> I'm getting the following compile error due to the 0 assignment
> to tb->fastuid:
>
> net/ipv4/inet_connection_sock.c: In function =91inet_csk_get_port=92:
> net/ipv4/inet_connection_sock.c:232:16: error: incompatible types whe=
n assigning to type =91kuid_t=92 from type =91int=92
> net/ipv4/inet_connection_sock.c:241:16: error: incompatible types whe=
n assigning to type =91kuid_t=92 from type =91int=92
>   CC      lib/show_mem.o
>   CC      net/ipv6/ipv6_sockglue.o
> make[3]: *** [net/ipv4/inet_connection_sock.o] Error 1
> make[2]: *** [net/ipv4] Error 2
>
> I have not seen this reported so far what surprises me a bit.
> This is net-next from today complied with
> gcc (Ubuntu/Linaro 4.6.3-1ubuntu5) 4.6.3
