From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v2 1/2] net: Added mtu parameter to
 dev_forward_skb calls
Date: Thu, 11 May 2017 12:44:54 -0700
Message-ID: <20170511124454.473dd56e@xeon-e3>
References: <20170511134629.139528-1-fredrik.markstrom@gmail.com>
	<20170511134629.139528-2-fredrik.markstrom@gmail.com>
	<20170511090132.79fdbf12@xeon-e3>
	<CAKdL+dS_-UiHA5tr7zP-5LtwDd0aXpZq5tpMYf9kr7hu2SwdGQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	Alexei Starovoitov <ast@kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Fredrik =?UTF-8?B?TWFya3N0csO2bQ==?= <fredrik.markstrom@gmail.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <CAKdL+dS_-UiHA5tr7zP-5LtwDd0aXpZq5tpMYf9kr7hu2SwdGQ@mail.gmail.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Thu, 11 May 2017 21:10:11 +0200
Fredrik Markstr=C3=B6m <fredrik.markstrom@gmail.com> wrote:

> On Thu, May 11, 2017 at 6:01 PM, Stephen Hemminger
> <stephen@networkplumber.org> wrote:
> > On Thu, 11 May 2017 15:46:27 +0200
> > Fredrik Markstrom <fredrik.markstrom@gmail.com> wrote:
> > =20
> >> From: Fredrik Markstr=C3=B6m <fredrik.markstrom@gmail.com>
> >>
> >> is_skb_forwardable() currently checks if the packet size is <=3D mtu of
> >> the receiving interface. This is not consistent with most of the hardw=
are
> >> ethernet drivers that happily receives packets larger then MTU. =20
> >
> > Wrong. =20
>=20
> What is "Wrong" ? I was initially skeptical to implement this patch,
> since it feels odd to have different MTU:s set on the two sides of a
> link. After consulting some IP people and the RFC:s I kind of changed
> my mind and thought I'd give it a shot. In the RFCs I couldn't find
> anything that defined when and when not a received packet should be
> dropped.
>=20
> >
> > Hardware interfaces are free to drop any packet greater than MTU (actua=
lly MTU + VLAN).
> > The actual limit is a function of the hardware. Some hardware can only =
limit by
> > power of 2; some can only limit frames larger than 1500; some have no l=
imiting at all. =20
>=20
> Agreed. The purpose of these patches is to be able to configure an
> veth interface to mimic these different behaviors. Non of the Ethernet
> interfaces I have access to drops packets due to them being larger
> then the configured MTU like veth does.
>=20
> Being able to mimic real Ethernet hardware is useful when
> consolidating hardware using containers/namespaces.
>=20
> In a reply to a comment from David Miller in my previous version of
> the patch I attached the example below to demonstrate the case in
> detail.
>=20
> This works with all ethernet hardware setups I have access to:
>=20

Why not just use an iptables rule to enforce what ever semantic you
want?
