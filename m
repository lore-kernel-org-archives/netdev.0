From: =?iso-8859-1?Q?Fran=E7ois-Xavier_Le_Bail?= <fx.lebail@yahoo.com>
Subject: Re: [PATCH net-next] IPv6: add option to use anycast addresses as source addresses in icmp error messages
Date: Wed, 15 Jan 2014 01:46:03 -0800 (PST)
Message-ID: <1389779163.69122.YahooMailBasic@web125504.mail.ne1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org, Bill Fink <billfink@mindspring.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki Yoshifuji <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm49.bullet.mail.ne1.yahoo.com ([98.138.120.56]:41726 "HELO
	nm49.bullet.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750754AbaAOJtG convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jan 2014 04:49:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 14, 2014 at 02:13:44PM +0100, Hannes Frederic Sowa wrote:
> > On Mon, Jan 13, 2014 at 06:22:44PM +0100, Francois-Xavier Le Bail w=
rote:
> > > - Add "anycast_src_icmp_error" sysctl to control the use of anyca=
st addresses
> > >=A0=A0=A0as source addresses for ICMPv6 error messages. This sysct=
l is false by
> > >=A0=A0=A0default to preserve existing behavior.
> > > - Use it in icmp6_send().
> > >=20
> > > Suggested-by: Bill Fink <billfink@mindspring.com>
> > > Signed-off-by: Francois-Xavier Le Bail <fx.lebail@yahoo.com>
> >=20
> > Regarding the anycast patches, I contacted someone from IETF.
> >=20
> > The number of sysctls needed to get introduced to have all the flex=
ibility
> > regarding source address selection and don't break backward compati=
bility
> > concerns me a bit.
> >=20
> > Especially on end hosts, where those switches will be important, I =
think we
> > really have to think about sensible defaults without breaking curre=
nt
> > software.
> >=20
> > I currently consider a per-address flag, if those anycast addresses
> > should be available in source address selection (also with an enhan=
cement to
> > current IPV6_JOIN_ANYCAST logic).
>=20
> Francois, we should really think about this. Also if we should just
> make the pre-defined subnet address just a normal anycast address in =
the
> long-term (which just happens to get automatically added to an interf=
ace
> if forwarding is enabled) and bundle all the source address selection
> logic on the per-address state.

Hi Hannes,

Please submit patches with your solution, so that we can have a basis
for discussion.

> If that would be the case, we could revert
> 509aba3b0d366b7f16a9a2eebac1156b25f5f622 ("IPv6: add the option to us=
e
> anycast addresses as source addresses in echo reply") and thus would
> eliminate one sysctl.

If your solution achieve the same goal without this sysctl, I agree wit=
h you.

> It would be fine if we can make this decision before David merges wit=
h
> Linus.=A0 I guess we can still do this decision while in -rc phase. B=
ut
> as soon as the knob is in a released version of linux we can never ta=
ke
> it back (I really don't like sysctls).

Sure.

Cheers,
=46ran=E7ois-Xavier
