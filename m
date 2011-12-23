From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: netem and hierarchical ingress traffic shaping
Date: Fri, 23 Dec 2011 11:07:49 -0800
Message-ID: <20111223110749.7a690685@nehalam.linuxnetplumber.net>
References: <1324185132.8451.439.camel@denise.theartistscloset.com>
	<20111218115549.0d9e1259@nehalam.linuxnetplumber.net>
	<1324661639.4540.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1324661950.4540.20.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<CAA93jw77tL88oxt=2ZTs68k5awCOO2f4d+aE9H-yQdTsd8=gAQ@mail.gmail.com>
	<1324664907.2915.5.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dave Taht <dave.taht@gmail.com>,
	"John A. Sullivan III" <jsullivan@opensourcedevel.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:52133 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753852Ab1LWTHw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Dec 2011 14:07:52 -0500
In-Reply-To: <1324664907.2915.5.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 23 Dec 2011 19:28:27 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le vendredi 23 d=E9cembre 2011 =E0 18:54 +0100, Dave Taht a =E9crit :
>=20
> > Are there any place where all 48 bytes of cb are used?
> >=20
>=20
> Yes, but on in qdisc layer.
>=20
> struct tcp_skb_cb is known to be 44 bytes (when IPv6 is enabled)
>=20
> In qdisc layer, we use a small part of it, for the moment.
>=20
> > I wouldn't mind if 'time_to_send' became a separate skb field
> > for a more generic 'time_in_queue'...
> >=20
>=20
> This wont happen.
>=20
> As I posted in an earlier patch, this can be added in "struct
> qdisc_skb_cb"
>=20
>=20
>=20

skb_cb is the dumping ground of the networking layer.
The assumption was that the qdisc could use the skb_cb
for it's own scratchpad. Netem is using it for tagging
packets in the queue.=20

So basically, netem, choke, and sfb are incompatible with
each other. This is not that bad, why not add a flag to qdisc
ops to indicate which qdisc are using cb and block user from
trying to do something bogus.
