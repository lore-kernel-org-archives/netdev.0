From: Ran Shalit <ranshalit@gmail.com>
Subject: Re: Q: How to disable vlan strip in Intel igb driver ?
Date: Mon, 2 May 2016 08:12:36 +0300
Message-ID: <CAJ2oMhL49ovpfUeXQeL6RayUENB62KtHXVwUDXZWPkRGYHQF6g@mail.gmail.com>
References: <CAJ2oMhKyMbgLZiGSGQxRGVdbGARvMHeO3=vpgO0uOzOBqvf79Q@mail.gmail.com>
	<afa69dcb-0905-a556-0208-49a2363ae818@fri.uniza.sk>
	<CAJ2oMhJp9M93QujnPYmp5CQkt-tx8P-uRCveiMEkDRLrcZmNhg@mail.gmail.com>
	<add3dc34-51fc-73e2-489a-e3230cc081f6@fri.uniza.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Alexander Duyck <alexander.duyck@gmail.com>
To: =?UTF-8?Q?Peter_Pal=C3=BAch?= <Peter.Paluch@fri.uniza.sk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:36524 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750738AbcEBFMh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 May 2016 01:12:37 -0400
Received: by mail-ig0-f181.google.com with SMTP id u10so75099083igr.1
        for <netdev@vger.kernel.org>; Sun, 01 May 2016 22:12:36 -0700 (PDT)
In-Reply-To: <add3dc34-51fc-73e2-489a-e3230cc081f6@fri.uniza.sk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 1, 2016 at 11:51 PM, Peter Pal=C3=BAch <Peter.Paluch@fri.un=
iza.sk> wrote:
> Hi Ran,
>
>
>> Alex,
>> I don't see rx-vlan-offload option in my ethtool. strange, maybe it =
is
>> not available in all ethtool versions ?
>
>
> According to my manpage for ethtool v4.5, the relevant -K option is
> "rxvlan".
>
>> Hi Peter,
>> Yes, I'm using AF_PACKET (I can't validate it now for 100%, but I
>> quite sure about it).
>
>
> Okay - but I assume that you are writing a userspace application, not=
 a
> kernelspace driver or module, right?
>
>> I'm accessing the ethernet header, and it always gives me non extend=
ed
>> ethernet header (without vlan information).
>
>
> It seems that this behavior has been around for a long time, and is
> intentional. See the following thread for more information:
>
> http://www.spinics.net/lists/netdev/msg244668.html
>
> The only legit way of accessing VLAN tag info on an AF_PACKET socket =
I know
> about is by setting the PACKET_AUXDATA socket option, and reading the
> auxiliary data as a struct tpacket_auxdata using recvmsg().
>
> In addition, however, there seems to be a bug in the kernel in that t=
he
> tp_vlan_tci member of the struct tpacket_auxdata is filled in only if=
 the
> AF_PACKET socket is bound to htons(ETH_P_ALL). If the socket is bound=
 to any
> other specific protocol, the tp_vlan_tci is set to 0. I have raised t=
his
> issue recently in the following thread(s) but have not received a res=
ponse
> yet:
>
> http://www.spinics.net/lists/netdev/msg372830.html
> http://www.spinics.net/lists/netdev/msg373112.html
>
>
>> I can see the vlan tag in vlan_tci field in sk_buff, but this is not
>> exactly what I need, I need the header AS-IS with the original
>> (extended) ethernet header.
>
>
> How are you accessing the vlan_tci field from your software?
>
> In any case, with AF_PACKET sockets, I am afraid you don't have much =
choice.
> Even libpcap reconstructs VLAN-tagged frames by reading the VLAN tag =
from an
> auxiliary structure and then re-inserting it into the frame, because =
the
> frame delivered through an AF_PACKET socket does not have the VLAN ta=
g
> present anymore.
>

Hi Peter,

I have a patch (hook) in the igb (Intel) driver which reads the skb
buffer into our buffer, this is without using socket actually. ipstack
is not involved, so socket as
I mentioned before are not relevant (AF_PACKET not relevant).
the problem seems in the driver that the driver strip vlan information
(there is a lot of mention of strip and vlan in the igb driver, and I
tried many things, but still it always strip this information from the
data in the sk_buff.)
will ethtool assist in this case ? I don;t see any vlan option in my
ethtool. Does ethtool communicated with the driver and command it not
to strip the vlan info ?

Thanks,
Ran
