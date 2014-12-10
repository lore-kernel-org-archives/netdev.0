From: Linus =?utf-8?Q?L=C3=BCssing?= <linus.luessing@c0d3.blue>
Subject: Re: Multicast packets being lost (3.10 stable)
Date: Wed, 10 Dec 2014 20:16:33 +0100
Message-ID: <20141210191633.GA2473@odroid>
References: <20140324094107.2cfbf103@nehalam.linuxnetplumber.net>
	<20140325125231.GW6008@Linus-Debian> <20140910133341.GI7058@odroid>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: Stephen Hemminger <shemming@brocade.com>, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	openwrt-devel@lists.openwrt.org, David Miller <davem@davemloft.net>
To: David Miller <davem@davemloft.net>
Return-path: <bridge-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20140910133341.GI7058@odroid>
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

Hi David,

did you have a chance to look into backporting these fixes for
stable yet? (if I read the docs correctly, I should query you for
suggestions for stable kernels, right?)

Also, an eighth patch I'd suggest for stable now:

8) bridge: fix netfilter/NF_BR_LOCAL_OUT for own, locally generated queri=
es
   -> f0b4eeced (since 3.18)


If there's anything unclear, just let me know. Thanks :)!

Cheers, Linus


On Wed, Sep 10, 2014 at 03:33:41PM +0200, Linus L=C3=BCssing wrote:
> I just got a complaint about bridges, multicast and a
> 3.10 kernel again. Seems like nobody had any objections about
> queueing these two patches for stable ( 2)+3) )?
>=20
> Also I'm still missing some more fixes in the stable branches.
> Especially 5), 6) and 7) are of high priority (next to 2) and 3) )
> in my opinion as otherwise IPv6 in general could be broken for people
> using 3.12 or 3.13 (as 3.12 contains a patch which activates
> multicast snooping for link-local addresses, too: 3c3769e63).
>=20
> Here is a more ordered list of patches I'd suggest to be queued for
> stable:
>=20
> 1) bridge: fix switched interval for MLD Query types
>    ->=E2=80=AF32de868cb (present since 3.10)
> 2) bridge: disable snooping if there is no querier
>    ->=E2=80=AFb00589af3 (present since 3.11)
> 3) bridge: don't try to update timers in case of broken MLD queries
>    -> 248ba8ec0 (present since 3.11)
> 4) Revert "bridge: only expire the mdb entry when query is received"
>    ->=E2=80=AF454594f3b (present since 3.12)
> 5) bridge: multicast: add sanity check for query source addresses
>    ->=E2=80=AF6565b9eee (present since 3.14)
> 6) bridge: multicast: add sanity check for general query destination
>    ->=E2=80=AF9ed973cc4 (present since 3.14)
> 7) bridge: multicast: enable snooping on general queries only
>    ->=E2=80=AF20a599bec (present since 3.14)
>=20
> Let me know what you'd think about that or if there's any trouble
> applying them to older kernels.
>=20
> Cheers, Linus
>=20
>=20
> On Tue, Mar 25, 2014 at 02:06:07PM +0100, Linus L=C3=BCssing wrote:
> > That commit is supposed to be a fix and seems to be a easily
> > cherry-pickable on top of 3.10. So I think it's suitable for
> > stable
> >=20
> > There are two follow-up commit for this particular patch that I'm awa=
re
> > of: "bridge: separate querier and query timer into IGMP/IPv4
> > and MLD/IPv6 ones" (cc0fdd80). That's just an optimization
> > and can be ignored for stable.
> >=20
> > The second one is "bridge: don't try to update timers in case of
> > broken MLD queries" (248ba8ec0). Which is a direct fix for
> > b00589af3 and should therefore go into stable, too, if b00589af3
> > goes into stable.
> >=20
> > Cheers, Linus
> >=20
> >=20
> > On Mon, Mar 24, 2014 at 09:41:07AM -0700, Stephen Hemminger wrote:
> > > We are seeing multicast snooping related issues.
> > > Is there some reason this commit never went into stable (3.10)
> > >=20
> > > commit b00589af3b04736376f24625ab0b394642e89e29
> > > Author: Linus L=C3=BCssing <linus.luessing@web.de>
> > > Date:   Thu Aug 1 01:06:20 2013 +0200
> > >=20
> > >     bridge: disable snooping if there is no querier
> > >    =20
> > >     If there is no querier on a link then we won't get periodic rep=
orts and
> > >     therefore won't be able to learn about multicast listeners behi=
nd ports,
> > >     potentially leading to lost multicast packets, especially for m=
ulticast
> > >     listeners that joined before the creation of the bridge.
> > >    =20
> > >     These lost multicast packets can appear since c5c23260594
> > >     ("bridge: Add multicast_querier toggle and disable queries by d=
efault")
> > >     in particular.
> > >    =20
> > >     With this patch we are flooding multicast packets if our querie=
r is
> > >     disabled and if we didn't detect any other querier.
> > >    =20
> > >     A grace period of the Maximum Response Delay of the querier is =
added to
> > >     give multicast responses enough time to arrive and to be learne=
d from
> > >     before disabling the flooding behaviour again.
> > >    =20
> > >     Signed-off-by: Linus L=C3=BCssing <linus.luessing@web.de>
> > >     Signed-off-by: David S. Miller <davem@davemloft.net>
