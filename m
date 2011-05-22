From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [patch net-next-2.6 v2] net: vlan: make non-hw-accel rx path
 similar to hw-accel
Date: Sun, 22 May 2011 10:52:28 +0200
Message-ID: <BANLkTi=B4c-A9ZC2apE+ZOQmgdzaJb0oEQ@mail.gmail.com>
References: <1302241713-3637-1-git-send-email-jpirko@redhat.com>
 <20110412.141645.112604563.davem@davemloft.net> <BANLkTikSKiYoiOLB=i7qjR0N--CAQ2dHWw@mail.gmail.com>
 <20110521072925.GA2588@jirka.orion> <BANLkTinZUATEjBij+rwBTn=n-Tau5qHPWw@mail.gmail.com>
 <4DD7BB61.9050200@gmail.com> <BANLkTinqFJa-B7E7tonzOKGV4etZHUkUug@mail.gmail.com>
 <4DD87C25.4030701@gmail.com> <20110522062915.GA2611@jirka.orion>
 <m17h9jp7js.fsf@fess.ebiederm.org> <4DD8CA87.8040905@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Pirko <jpirko@redhat.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Jesse Gross <jesse@nicira.com>,
	Changli Gao <xiaosuo@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	shemminger@linux-foundation.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, andy@greyhouse.net
To: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:64966 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752227Ab1EVIwt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 May 2011 04:52:49 -0400
Received: by qwk3 with SMTP id 3so2407157qwk.19
        for <netdev@vger.kernel.org>; Sun, 22 May 2011 01:52:48 -0700 (PDT)
In-Reply-To: <4DD8CA87.8040905@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/5/22 Nicolas de Peslo=C3=BCan <nicolas.2p.debian@gmail.com>:
> Le 22/05/2011 08:34, Eric W. Biederman a =C3=A9crit :
>>
>> Jiri Pirko<jpirko@redhat.com> =C2=A0writes:
>>
>>> Sun, May 22, 2011 at 04:59:49AM CEST, nicolas.2p.debian@gmail.com w=
rote:
>>>
>>> <snip>
>>>>
>>>> And because some setups may still require the skb not to be untagg=
ed,
>>>> may be we need the ability to re-tag the skb in some situations...
>>>> When a protocol handler or rx_handler is explicitly registered on =
a
>>>> net_device which expect to receive tagged skb, we should deliver
>>>> tagged skb to it... Arguably, this may sound incredible for the
>>>> general case, but may be required for not-so-special cases like
>>>> bridge or protocol analyzer.
>>>
>>> Wait, what setups/code require the skb not to be untagged? If there=
's
>>> such, it should be fixed.
>>
>> tcpdump on the non-vlan interface for one.
> bridge is another. More precisely, there is a difference between the
> following two setups:
>
> 1/ eth0 - eth0.100 - br0 - eth1.200 - eth1
>
> 2/ eth0 - br0 - eth1
>
> In case 1, it is normal and desirable for the bridge to see untagged =
skb.
>
> In case 2, it is desirable for the bridge to see untouched (possibly =
tagged)
> skb. If current bridge implementation is able to handle skb from whic=
h we
> removed a tag, in this situation, it means that bridge currently "fix
> improper untagging" by itself, by forcing re-tagging on output. I thi=
nk is
> should not be the job of protocol handlers to fix this. Again, a gene=
ric
> feature should to it when necessary.
>
> Think of the following setups:
>
> 3/ eth0 - br0 - eth1.200 - eth1.
> 4/ eth0 - eth0.100 - br0 - eth1
>
> What if one expect this setup to add (3) or remove (4) one level of v=
lan
> nesting? This is precisely what this setup suggest. How can we instru=
ct the
> bridge to do so? It is not the bridge responsibility to do any vlan
> processing. bridge is expected to... bridge !

I assumed that this untaging Jiri is implementing does not remove the
tag. It moves the information from skb->data to skb->vlan_tci, but the
information contained is not otherwise changing. All your examples
should work regardless of where the tag is stored.

Best Regards,
Micha=C5=82 Miros=C5=82aw
