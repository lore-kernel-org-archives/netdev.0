From: Wolfgang Walter <wolfgang.walter@studentenwerk.mhn.de>
Subject: Re: Problem with IPSEC tunnel mode
Date: Fri, 22 Apr 2005 13:42:10 +0200
Message-ID: <200504221342.10675.wolfgang.walter@studentenwerk.mhn.de>
References: <E1DObFc-0000je-00@gondolin.me.apana.org.au> <20050421235802.GB10451@gondor.apana.org.au> <1114129099.10572.24.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: quoted-printable
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1114129099.10572.24.camel@localhost.localdomain>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Am Freitag, 22. April 2005 02:18 schrieb jamal:
> On Fri, 2005-22-04 at 09:58 +1000, Herbert Xu wrote:
> > On Thu, Apr 21, 2005 at 07:50:19PM -0400, jamal wrote:
> > > What was the reason there exist a FWD direction in the policies?
> >
> > You should really ask Alexey about that :) I myself had the same
> > question when I first started in this area.  However, since it
> > has been present since the very beginning and people are already
> > relying on it, we will have to live with it.
>
> I am sure if Alexey did it theres a good reason - I am not sure i get
> it. CCing mr Kuznet.
>
> > > Also - shouldnt the FWD policies closely match the OUT ones instead=
 of
> > > the IN direction (browsing the forwarding code)? i.e
> > > does this look odd to you (picking a sample from Wolfgangs output):
> >
> > The FWD policies are analogous to the FORWARD table in netfilter.
> > The FWD policies apply to forwarded packet, meaning packets that
> > end up in ip_forward instead of ip_local_deliver.  The IN policies
> > only apply to packets that end up in ip_local_deliver.
>
> Heres what confused me when i browsed:
> looking at ip_forward() - it does a xfrm4_policy_check(NULL,
> XFRM_POLICY_FWD, skb)  - this leads to a flow cache creation based on
> FWD direction. Later on in the path (still in ip_forward)
> xfrm4_route_forward() gets invoked which does a flow_cache build again
> based on XFRM_POLICY_OUT.
> So i was wondering whether they OUT shouldnt be just a duplicate of
> FWD (instead FWD seems to be the dup of IN). Look at that sample i
> posted - all his policies look like that. What gives? Why are the IN an=
d
> FWD exactly the same? bug in racoon/setkey?
>
> cheers,
> jamal

No. XFRM_POLICY_IN is only checked for incoming packets which are deliver=
ed=20
locally.

XFRM_POLICY_FWD is checked for incoming packets which are routed.

That our XFRM_POLICY_IN matches XFRM_POLICY_FWD is more for convenience: =
if a=20
subnet is connected directly to a router we want to treat the interface=20
address of the router itself the same way. Instead of constructing specia=
l=20
rules which exactly match the interface address we simply use the same ru=
le=20
as for forwarding.

XFRM_POLICY_OUT ist checked for every outgoing packet, be it locally gene=
rated=20
be it routed (which is different from netfilter).

This asymmetry is a little bit inconsequent. Probably one should really h=
ave=20
XFRM_POLICY_FWD_IN and XFRM_POLICY_FWD_OUT. But XFRM_POLICY_OUT would mai=
nly=20
be a copy of XFRM_POLICY_FWD_OUT then, I think.

Greetings,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
Leopoldstra=DFe 15
80802 M=FCnchen
