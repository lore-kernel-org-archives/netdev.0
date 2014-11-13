From: =?windows-1252?Q?J=F6rg_Marx?= <joerg.marx@secunet.com>
Subject: Re: [PATCH nf] netfilter: conntrack: fix race in __nf_conntrack_confirm
 against get_next_corpse
Date: Thu, 13 Nov 2014 15:33:59 +0100
Message-ID: <5464C157.7020901@secunet.com>
References: <012601cff7d1$7ce2d620$76a88260$@gmail.com> <20141106133648.2534.1403.stgit@dragon> <20141110165439.GA7788@salvia> <20141112083500.5404e5f4@redhat.com> <54633D1B.5090404@secunet.com> <20141113120826.GA8224@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	<programme110@gmail.com>, <netfilter-devel@vger.kernel.org>,
	Florian Westphal <fw@strlen.de>, <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20141113120826.GA8224@salvia>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 13.11.2014 13:08, Pablo Neira Ayuso wrote:

>> For me there is little difference in choosing DROP or ACCEPT as verd=
ict.
>> > The packet/skb belongs to a formerly allowed connection, most like=
ly
>> > this connection is still allowed (but the conntrack hash entry is =
about
>> > to be removed due to userspace is flushing the conntrack table).
> __nf_conntrack_confirm() is only called for the first packet that we
> see in a flow. If you just invoked the flush command once (which
> should be the common case), then this is likely to be the first packe=
t
> of the flow (unless you already called flush anytime soon in the
> past).
Yes, you are right. As far as I remember it was very hard to trigger
that critical moment, when the first packet triggered the insertion int=
o
the hash table. But the test and production systems showed this strange
behaviour, that no traffic was allowed to flow for exactly 600 seconds.

>=20
>> > To minimize the impact (lost packets -> retransmit) I decided to a=
llow
>> > the skb in flight, so were is no lost packet at this place.
> I understand your original motivation was to be conservative.
Yes.

>=20
>> > When the connection is not allowed anymore (but was allowed up to =
now,
>> > because the hash entry exists), the impact is one last packet 'sli=
pping
>> > through'.
=46eel free to change the verdict, IMHO it doesn't matter at all as lon=
g
as the hash table is in a consistent state. The higher protocol layers
will deal with the missing packet.

> The general policy in conntrack is to not drop packets, but in this
> case we'll leave things in inconsistent state (ie. we will likely
> receive a reply packet in response to the original packet that has no
> conntrack yet).
Under heavy load this can happen anyway I guess?

Thanks and best regards
J=F6rg

--=20
Dipl.-Inform.
J=F6rg Marx
Bereichsleiter
Entwicklung Client- & Netzwerksicherheit
Gesch=E4ftsbereich Public Sector
secunet Security Networks AG
Ammonstr. 74
D-01067 Dresden, Germany=20
Telefon +49 201 54 54-3517
Telefax +49 201 54 54-1323
joerg.marx@secunet.com
www.secunet.com

secunet Security Networks AG
Kronprinzenstr. 30
45128 Essen, Germany=20
Amtsgericht Essen HRB 13615

Vorstand: Dr. Rainer Baumgart (Vors.), Thomas Pleines
Aufsichtsratsvorsitzender: Dr. Peter Zattler
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
