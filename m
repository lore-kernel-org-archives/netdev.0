From: =?ISO-8859-1?Q?Mika_Penttil=E4?= <mika.penttila@kolumbus.fi>
Subject: Re: [PATCH] Fix checksum bug for multicast/broadcast packets on postrouting
 hook
Date: Sun, 15 Feb 2004 11:34:22 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <402F3D1E.2020005@kolumbus.fi>
References: <Xine.LNX.4.44.0402142314580.7364-100000@thoron.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: "David S. Miller" <davem@redhat.com>, Harald Welte <laforge@netfilter.org>,
        netdev@oss.sgi.com, Stephen Smalley <sds@epoch.ncsc.mil>
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@redhat.com>
In-Reply-To: <Xine.LNX.4.44.0402142314580.7364-100000@thoron.boston.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



James Morris wrote:

>On Sat, 14 Feb 2004, Mika Penttil=E4 wrote:
>
> =20
>
>>James Morris wrote:
>>
>>   =20
>>
>>>The proposed solution below is to copy the skb rather than clone it, t=
o=20
>>>ensure that the original and looped back packets are independent.
>>>
>>>     =20
>>>
>>This is unneeded overhead for the common case. The right fix is to make=
=20
>>sure the modifier (netfilter etc) makes the copy if needed. Actually,=20
>>this is what skb_ip_make_writable() is doing.
>>   =20
>>
>
>The common case here will be only for locally generated multicast and=20
>broadcast packets.
>
>If the netfilter core code is modified instead, we will end up adding
>skb_ip_make_writable() to nf_hook_slow() which will be called for every=20
>packet with an output device which uses hardware checksums.
>
>Not sure which is worse, but here's a proposed patch which does this.
>
>
>- James
>

I don't see the context here. Where is the packet mangled? Why isn't=20
that instance doing skb_ip_make_writable()? selinux? Not everyone=20
generating locally multicast/broadcast packets is using selinux...

--Mika
