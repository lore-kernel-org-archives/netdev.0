From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next-2.6 v2] net: vlan: make non-hw-accel rx path
 similar to hw-accel
Date: Sun, 22 May 2011 11:36:16 +0200
Message-ID: <20110522093614.GB2611@jirka.orion>
References: <BANLkTinZUATEjBij+rwBTn=n-Tau5qHPWw@mail.gmail.com>
 <4DD7BB61.9050200@gmail.com>
 <BANLkTinqFJa-B7E7tonzOKGV4etZHUkUug@mail.gmail.com>
 <4DD87C25.4030701@gmail.com>
 <20110522062915.GA2611@jirka.orion>
 <m17h9jp7js.fsf@fess.ebiederm.org>
 <4DD8CA87.8040905@gmail.com>
 <BANLkTi=B4c-A9ZC2apE+ZOQmgdzaJb0oEQ@mail.gmail.com>
 <4DD8D2FE.4080204@gmail.com>
 <BANLkTimQ6LAWbZMCjBhqA5By8jvxwnfjVg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Nicolas de =?iso-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Jesse Gross <jesse@nicira.com>,
	Changli Gao <xiaosuo@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	shemminger@linux-foundation.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, andy@greyhouse.net
To: =?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39041 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750982Ab1EVJgn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 May 2011 05:36:43 -0400
Content-Disposition: inline
In-Reply-To: <BANLkTimQ6LAWbZMCjBhqA5By8jvxwnfjVg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, May 22, 2011 at 11:20:09AM CEST, mirqus@gmail.com wrote:
>W dniu 22 maja 2011 11:10 u=C5=BCytkownik Nicolas de Peslo=C3=BCan
><nicolas.2p.debian@gmail.com> napisa=C5=82:
>> Le 22/05/2011 10:52, Micha=C5=82 Miros=C5=82aw a =C3=A9crit :
>>>
>>> 2011/5/22 Nicolas de Peslo=C3=BCan<nicolas.2p.debian@gmail.com>:
>>>>
>>>> Le 22/05/2011 08:34, Eric W. Biederman a =C3=A9crit :
>>>>>
>>>>> Jiri Pirko<jpirko@redhat.com> =C2=A0 =C2=A0writes:
>>>>>
>>>>>> Sun, May 22, 2011 at 04:59:49AM CEST, nicolas.2p.debian@gmail.co=
m
>>>>>> wrote:
>>>>>>
>>>>>> <snip>
>>>>>>>
>>>>>>> And because some setups may still require the skb not to be unt=
agged,
>>>>>>> may be we need the ability to re-tag the skb in some situations=
=2E..
>>>>>>> When a protocol handler or rx_handler is explicitly registered =
on a
>>>>>>> net_device which expect to receive tagged skb, we should delive=
r
>>>>>>> tagged skb to it... Arguably, this may sound incredible for the
>>>>>>> general case, but may be required for not-so-special cases like
>>>>>>> bridge or protocol analyzer.
>>>>>>
>>>>>> Wait, what setups/code require the skb not to be untagged? If th=
ere's
>>>>>> such, it should be fixed.
>>>>>
>>>>> tcpdump on the non-vlan interface for one.
>>>>
>>>> bridge is another. More precisely, there is a difference between t=
he
>>>> following two setups:
>>>>
>>>> 1/ eth0 - eth0.100 - br0 - eth1.200 - eth1
>>>>
>>>> 2/ eth0 - br0 - eth1
>>>>
>>>> In case 1, it is normal and desirable for the bridge to see untagg=
ed skb.
>>>>
>>>> In case 2, it is desirable for the bridge to see untouched (possib=
ly
>>>> tagged)
>>>> skb. If current bridge implementation is able to handle skb from w=
hich we
>>>> removed a tag, in this situation, it means that bridge currently "=
fix
>>>> improper untagging" by itself, by forcing re-tagging on output. I =
think
>>>> is
>>>> should not be the job of protocol handlers to fix this. Again, a g=
eneric
>>>> feature should to it when necessary.
>>>>
>>>> Think of the following setups:
>>>>
>>>> 3/ eth0 - br0 - eth1.200 - eth1.
>>>> 4/ eth0 - eth0.100 - br0 - eth1
>>>>
>>>> What if one expect this setup to add (3) or remove (4) one level o=
f vlan
>>>> nesting? This is precisely what this setup suggest. How can we ins=
truct
>>>> the
>>>> bridge to do so? It is not the bridge responsibility to do any vla=
n
>>>> processing. bridge is expected to... bridge !
>>>
>>> I assumed that this untaging Jiri is implementing does not remove t=
he
>>> tag. It moves the information from skb->data to skb->vlan_tci, but =
the
>>> information contained is not otherwise changing. All your examples
>>> should work regardless of where the tag is stored.
>>
>> I assumed (but didn't tested) that this untagging also change the st=
arting
>> point of the payload of the packet. So protocol handlers expecting t=
o have
>> the raw packet won't see the vlan header.
>
>That would also be the case with hardware stripped tags - they need to
>look into skb->vlan_tci anyway.

Exactly. Nicolas, I do not see anything wrong on always untagging in al=
l
your setups. As Michal said, vlan_tci keeps the info.

Jirka

>
>Best Regards,
>Micha=C5=82 Miros=C5=82aw
