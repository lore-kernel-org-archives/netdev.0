From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 1/2] Support outside netns for tunnels.
Date: Mon, 04 Jan 2016 11:54:08 -0800
Message-ID: <1451937248.4334.105.camel@perches.com>
References: <1451933147-17266-1-git-send-email-saurabh@cplanenetworks.com>
	 <CALx6S376Ay70TTP=UwSpo4aieZ3Rp7U4TNmdSCbKSqGDHcw3DA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Pravin B Shelar <pshelar@nicira.com>,
	Thomas Graf <tgraf@suug.ch>
To: Tom Herbert <tom@herbertland.com>,
	Saurabh Mohan <saurabh@cplanenetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0193.hostedemail.com ([216.40.44.193]:34462 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751922AbcADTyM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 14:54:12 -0500
In-Reply-To: <CALx6S376Ay70TTP=UwSpo4aieZ3Rp7U4TNmdSCbKSqGDHcw3DA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-01-04 at 11:47 -0800, Tom Herbert wrote:
> On Mon, Jan 4, 2016 at 10:45 AM, Saurabh Mohan
> <saurabh@cplanenetworks.com> wrote:
> >=20
> > This patch enchances a tunnel interface, like gre, to have the tunn=
el
> > encap/decap be in the context of a network namespace that is differ=
ent from
> > the namespace of the tunnel interface.
> >=20
> > From userspace this feature may be configured using the new 'onetns=
' keyword:
> > ip netns exec custa ip link add dev tun1 type gre local 10.0.0.1 \
> > =A0remote 10.0.0.2 onetns outside
> >=20
> > In the above example the tunnel would be in the 'custa' namespace a=
nd the
> > tunnel endpoints would be in the 'outside' namespace.
> >=20
> > Also, proposing the use of netns name 'global' to specify the globa=
l namespace.
> >=20
> > If this patch set is accepted then I will add support for other tun=
nels as
> > well.
> >=20
> This might be interesting. Can you please ad a 0/n patch that
> describes the motivation for this, in particular I would like to know
> if this has a positive impact on ns performance if somehow we are
> eliminating indirection.
[]
> > diff --git a/include/uapi/linux/if_tunnel.h b/include/uapi/linux/if=
_tunnel.h
[]
> > @@ -3,6 +3,7 @@
> >=20
> > =A0#include=20
> > =A0#include=20
> > +#include=20
> >=20
> >=20
> > =A0#define SIOCGETTUNNEL=A0=A0=A0(SIOCDEVPRIVATE + 0)
> > @@ -27,6 +28,14 @@
> > =A0#define GRE_FLAGS=A0=A0=A0=A0=A0=A0__cpu_to_be16(0x00F8)
> > =A0#define GRE_VERSION=A0=A0=A0=A0__cpu_to_be16(0x0007)
> >=20
> > +struct o_netns_parm {
> > +=A0=A0=A0=A0=A0=A0=A0__u8=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0o_netns_flag;
> > +=A0=A0=A0=A0=A0=A0=A0__u32=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0o_netns_fd;
> > +=A0=A0=A0=A0=A0=A0=A0char=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0netns[NAME_MAX];
> > +};

Trivia:

It could eliminate a few padding bytes if the
o_netns_fd and o_netns_flag fields were reversed.

and netns[NAME_MAX] is normally netns[NAME_MAX + 1]
