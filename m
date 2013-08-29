From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: separate querier and query timer into
 IGMP/IPv4 and MLD/IPv6 ones
Date: Wed, 28 Aug 2013 20:08:31 -0400 (EDT)
Message-ID: <20130828.200831.289304393401193657.davem@davemloft.net>
References: <1377511266-14530-1-git-send-email-linus.luessing@web.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: amwang@redhat.com, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	linux@baker-net.org.uk, stephen@networkplumber.org,
	herbert@gondor.apana.org.au
To: linus.luessing@web.de
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1377511266-14530-1-git-send-email-linus.luessing@web.de>
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

From: Linus L=FCssing <linus.luessing@web.de>
Date: Mon, 26 Aug 2013 12:01:06 +0200

> Currently we would still potentially suffer multicast packet loss if =
there
> is just either an IGMP or an MLD querier: For the former case, we wou=
ld
> possibly drop IPv6 multicast packets, for the latter IPv4 ones. This =
is
> because we are currently assuming that if either an IGMP or MLD queri=
er
> is present that the other one is present, too.
> =

> This patch makes the behaviour and fix added in
> "bridge: disable snooping if there is no querier" (b00589af3b04)
> to also work if there is either just an IGMP or an MLD querier on the=

> link: It refines the deactivation of the snooping to be protocol
> specific by using separate timers for the snooped IGMP and MLD querie=
s
> as well as separate timers for our internal IGMP and MLD queriers.
> =

> Signed-off-by: Linus L=FCssing <linus.luessing@web.de>

I think the logic of the fix is fine, but theres a lot of duplication
here.

Why not make a:

struct bridge_mcast_timer {
	struct	timer_list	timer;
	u32			queries_sent;
	u32			startup_queries_sent;

};

Then in the port structure you have:

	struct bridge_mcast_timer	ip4;
	struct bridge_mcast_timer	ip6;

And pass a reference to the right one into generic helper functions.

That sounds a lot better right?

Please make this improvement and resubmit, thanks.
