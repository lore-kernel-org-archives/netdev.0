From: Arvid Brodin <arvid.brodin@xdin.com>
Subject: Re: [PATCH v4] net/hsr: Add support for the High-availability Seamless
 Redundancy protocol (HSRv0)
Date: Tue, 15 Oct 2013 21:59:06 +0200
Message-ID: <525D9E8A.7090304@xdin.com>
References: <523A4F5E.9070503@xdin.com> <20130920.151017.2125552741552759738.davem@davemloft.net> <5249942F.3090504@xdin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, <shemminger@vyatta.com>,
	<joe@perches.com>, <jboticario@gmail.com>,
	<balferreira@googlemail.com>, <elias.molina@ehu.es>,
	Arvid Brodin <Arvid.Brodin@xdin.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spam1.webland.se ([91.207.112.90]:56535 "EHLO spam1.webland.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933444Ab3JOT7I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Oct 2013 15:59:08 -0400
In-Reply-To: <5249942F.3090504@xdin.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013-09-30 17:09, Arvid Brodin wrote:
> On 2013-09-20 21:10, David Miller wrote:
>> From: Arvid Brodin <arvid.brodin@xdin.com>
>> Date: Thu, 19 Sep 2013 03:11:58 +0200
>>
>>> +#if !defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS)
>>> +		/* We need to memmove the whole header to work around
>>> +		 * alignment problems caused by the 6-byte HSR tag.
>>> +		 */
>>> +		memmove(skb_deliver->data - HSR_TAGLEN, skb_deliver->data,
>>> +			skb_headlen(skb_deliver));
>>> +		skb_deliver->data -=3D HSR_TAGLEN;
>>> +		skb_deliver->tail -=3D HSR_TAGLEN;
>>> +#endif
>>
>> You can't do this.
>>
>> First of all, you have no idea if subtracting skb->data a given amou=
nt
>> will underflow the skb buffer start.  You aren't even checking, all
>> of the standard skb_*() data adjustment interfaces do.
>=20
> (Shorter and more to the point than my previous replies:)
>=20
> I _do_ know: this can't possibly underflow since strip_hsr_tag() a=20
> few lines above pulled the same amount of data. I will rename=20
> strip_hsr_tag() to hsr_pull_tag() to make this clearer.
>=20
>=20
>> Secondly, everything after the header is now at the wrong offset fro=
m
>> the beginning of the packet.
>=20
> How does this matter? The memmove moves everything back (restores the=
=20
> changes made to the packet on the sending side) so that it is at the
> "normal" position for an ethernet packet.
>=20

Obviously, David is too busy to help me figure out what the problem is=20
(I know he reviews several thousand patches each year, so maybe that's
no wonder).=20

If anyone else has got an idea you are very welcome to chime in, and
perhaps we can solve this. I can't fix the problem if I don't understan=
d
it.


On 2013-09-20 21:10, David Miller wrote:
> Secondly, everything after the header is now at the wrong offset from
> the beginning of the packet.

Maybe he's talking about systems with NET_SKBUFF_DATA_USES_OFFSET here?=
=20
This means the transport, network and mac headers are all relative to=20
skb->head, if I understand correctly. But at the point in the protocol=20
stack where this code is (the Ethernet protocol handler), the transport=
=20
and network headers have not been set yet, and the mac header is not
moved by the code. And tail is updated by the code. So that should not=20
be a problem?


--=20
Arvid Brodin | Consultant (Linux)
XDIN AB | Knarrarn=E4sgatan 7 | SE-164 40 Kista | Sweden | xdin.com
