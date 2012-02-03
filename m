From: Xiaochun Lu <xiaoclu@gmail.com>
Subject: Re: [PATCH v2] Implement IP_UNICAST_IF socket option.
Date: Thu, 2 Feb 2012 17:19:11 -0800
Message-ID: <CAOdseAOsGOD2bxOwQLZPq6KhL5xN9J81=d1tQWEULDZwxD9UxA@mail.gmail.com>
References: <1328218567-3134-1-git-send-email-ehoover@mines.edu>
	<1328219828.2480.32.camel@edumazet-laptop>
	<CAEU2+vrgxzTmiHWs-kVoKeu2_DcFZQBjCXwQfQ8dms5O6+Larg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Netdev <netdev@vger.kernel.org>,
	"shawn.lu" <shawn.lu@ericssion.com>
To: "Erich E. Hoover" <ehoover@mines.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:34203 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756407Ab2BCBTM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2012 20:19:12 -0500
Received: by yhoo21 with SMTP id o21so1428109yho.19
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2012 17:19:11 -0800 (PST)
In-Reply-To: <CAEU2+vrgxzTmiHWs-kVoKeu2_DcFZQBjCXwQfQ8dms5O6+Larg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Erich E. Hoover:

Can you give more detail on why we need invent another binding to
device option in your patch log?  Why SO_BINDTODEVICE or IP_PKTINFO
can't server your need?

Thanks!

Shawn Lu

On 2/2/12, Erich E. Hoover <ehoover@mines.edu> wrote:
> On Thu, Feb 2, 2012 at 2:57 PM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
>> Le jeudi 02 f=E9vrier 2012 =E0 14:36 -0700, Erich E. Hoover a =E9cri=
t :
>> > ...
>> > +             if (sk->sk_bound_dev_if && ifindex !=3D sk->sk_bound=
_dev_if)
>> > +                     break;
>>
>> what happens if later sk_bound_dev_if is changed ? Should we redo th=
e
>> above tests ?
>
> Would it be better if ip_default_ifindex performed the same compariso=
n
> and prioritized the sk->sk_bound_dev_if value?
>
>> > ...
>> > +     case IP_UNICAST_IF:
>> > +     {
>> > +             __be32 iface;
>> > +
>> > +             len =3D sizeof(__be32);
>> > +             iface =3D htonl(inet->outif_index);
>> > +             release_sock(sk);
>> > +
>> > +             if (put_user(len, optlen))
>> > +                     return -EFAULT;
>> > +             if (copy_to_user(optval, &iface, len))
>> > +                     return -EFAULT;
>> > +             return 0;
>>
>> wow.... thats not pretty...
>>
>>        what about :
>>
>>        case IP_UNICASE_IF:
>>                val =3D htonl(inet->outif_index);
>>                break;
>>
>
> The return value needs to be 4 bytes even if sizeof(int) !=3D 4.
>
>> > ...
>> IPv6 not supported ?
>
> Nope, at least according to the documentation the option is only for
> IPv4 (IPPROTO_IP).
>
> Erich Hoover
> ehoover@mines.edu
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
