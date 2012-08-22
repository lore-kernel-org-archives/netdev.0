From: "Hans Schillstrom" <hans@schillstrom.com>
Subject: Re[2]:  [PATCH 05/19] netfilter: nf_conntrack_ipv6: improve
	fragmentation handling
Date: Wed, 22 Aug 2012 07:01:24 +0200 (CEST)
Message-ID: <mdaatbj.b2f3561b17fe4f00a6e947611a0959a1@obelix.schillstrom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Patrick McHardy" <kaber@trash.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	"Julian Anastasov" <ja@ssi.bg>,
	"Hans Schillstrom" <hans.schillstrom@ericsson.com>
To: "Jesper Dangaard Brouer" <brouer@redhat.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi
>
>On Sun, 2012-08-19 at 21:44 +0200, Patrick McHardy wrote:
>> On Sun, 19 Aug 2012, Jesper Dangaard Brouer wrote:
>> > On Sat, 2012-08-18 at 14:26 +0200, Patrick McHardy wrote:
>[...]
>
>> > Don't I need to load some of the helper modules, or just the
>> > nf_conntrack_ipv6 module, or perhaps only nf_defrag_ipv6 ?
>>=20
>> Not with the entire patchset, just IPv6 conntrack is enough. Aith IP=
v6 NAT
>> the first packet of a connection must always be defragemented, indep=
endant
>> of an assigned helper.
>
>When loading "nf_conntrack_ipv6" I run into issues.
>
>When sending a fragmented UDP packet.  With these patches, the IPVS
>stack will no longer see the fragmented packets, but instead see one
>large SKB.  This will trigger a MTU path check in e.g.
>ip_vs_dr_xmit_v6() and an ICMPv6 too big packet is send back.
>
>  IPVS: ip_vs_dr_xmit_v6(): frag needed
>
>Perhaps we could change/fix the MTU check in IPVS?
>(This would also solve issues I've seen with TSO/GSO frames, hitting
>this code path).
>
I ran into this as well,=20
try this for the mtu check.

=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0if ((!skb->local_df && skb->l=
en > mtu && !skb_is_gso(skb)) ||
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 =C2=A0 =C2=A0(IP6CB(skb)->fr=
ag_max_size && IP6CB(skb)->frag_max_size > mtu)) {

/Hans

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
