From: =?ISO-8859-1?Q?Mika_Penttil=E4?= <mika.penttila@kolumbus.fi>
Subject: Re: [PATCH] Fix checksum bug for multicast/broadcast packets on postrouting
 hook
Date: Sun, 15 Feb 2004 15:40:18 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <402F76C2.6030300@kolumbus.fi>
References: <Xine.LNX.4.44.0402150801310.12126-100000@thoron.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: "David S. Miller" <davem@redhat.com>, Harald Welte <laforge@netfilter.org>,
        netdev@oss.sgi.com, Stephen Smalley <sds@epoch.ncsc.mil>
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@redhat.com>
In-Reply-To: <Xine.LNX.4.44.0402150801310.12126-100000@thoron.boston.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



James Morris wrote:

>On Sun, 15 Feb 2004, Mika Penttil=E4 wrote:
>
> =20
>
>>James Morris wrote:
>>
>>   =20
>>
>>>On Sat, 14 Feb 2004, Mika Penttil=E4 wrote:
>>>     =20
>>>
>>>>This is unneeded overhead for the common case. The right fix is to ma=
ke=20
>>>>sure the modifier (netfilter etc) makes the copy if needed. Actually,=
=20
>>>>this is what skb_ip_make_writable() is doing.
>>>>  =20
>>>>
>>>>       =20
>>>>
>>>The common case here will be only for locally generated multicast and=20
>>>broadcast packets.
>>>
>>>If the netfilter core code is modified instead, we will end up adding
>>>skb_ip_make_writable() to nf_hook_slow() which will be called for ever=
y=20
>>>packet with an output device which uses hardware checksums.
>>>
>>>Not sure which is worse, but here's a proposed patch which does this.
>>>
>>>
>>>- James
>>>
>>>     =20
>>>
>>I don't see the context here. Where is the packet mangled? Why isn't=20
>>that instance doing skb_ip_make_writable()? selinux? Not everyone=20
>>generating locally multicast/broadcast packets is using selinux...
>>
>>   =20
>>
>
>[my previous post didn't seem to make it to the list, newer patch is=20
>attached below again]
>
>The packet is mangled in skb_checksum_help(), which is called by the=20
>Netfilter core code.  It is not being mangled by SELinux.
>
>
>- James
>
skb_checksum_help() updates skb->ip_summed to CHECKSUM_NONE in the=20
original skb, and this should be seen by the driver. With your change=20
the checksum is calculated twice, once for the looping back packet, and=20
once for the outgoing.

--Mika
