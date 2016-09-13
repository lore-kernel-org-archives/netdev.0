From: Eric Dumazet via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: Re: README: [PATCH RFC 11/11] net/mlx5e: XDP TX xmit
 more
Date: Tue, 13 Sep 2016 08:58:30 -0700
Message-ID: <1473782310.18970.138.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1473252152-11379-1-git-send-email-saeedm@mellanox.com>
	<1473252152-11379-12-git-send-email-saeedm@mellanox.com>
	<20160908101147.1b351432@redhat.com>
	<20160909032202.GA62966@ast-mbp.thefacebook.com>
	<CALzJLG_r0pDJgxqqak5=NatT8tF7UP2NkGS1wjeWcS5C=Zvv2A@mail.gmail.com>
	<20160912121530.4b4f0ad7@redhat.com>
	<d8a477c6-5394-ab33-443f-59d75a58f430@solarflare.com>
Reply-To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org>,
	iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>,
	Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>, Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Return-path: <iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
In-Reply-To: <d8a477c6-5394-ab33-443f-59d75a58f430-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
List-Unsubscribe: <https://lists.iovisor.org/mailman/options/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.iovisor.org/pipermail/iovisor-dev/>
List-Post: <mailto:iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
List-Help: <mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=help>
List-Subscribe: <https://lists.iovisor.org/mailman/listinfo/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=subscribe>
Sender: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
Errors-To: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2016-09-13 at 16:20 +0100, Edward Cree wrote:
> On 12/09/16 11:15, Jesper Dangaard Brouer wrote:
> > I'm reacting so loudly, because this is a mental model switch, that
> > need to be applied to the full drivers RX path. Also for normal stack
> > delivery of SKBs. As both Edward Cree[1] and I[2] have demonstrated,
> > there is between 10%-25% perf gain here.
> >
> > [1] http://lists.openwall.net/netdev/2016/04/19/89
> > [2] http://lists.openwall.net/netdev/2016/01/15/51
> BTW, I'd also still rather like to see that happen, I never really
> understood the objections people had to those patches when I posted them.  I
> still believe that dealing in skb-lists instead of skbs, and thus
> 'automatically' bulking similar packets, is better than trying to categorise
> packets into flows early on based on some set of keys.  The problem with the
> latter approach is that there are now two definitions of "similar":
> 1) the set of fields used to index the flow
> 2) what will actually cause the stack's behaviour to differ if not using the
> cached values.
> Quite apart from the possibility of bugs if one changes but not the other,
> this forces (1) to be conservative, only considering things "similar" if the
> entire stack will.  Whereas with bundling, the stack can keep packets
> together until they reach a layer at which they are no longer "similar"
> enough.  Thus, for instance, packets with the same IP 3-tuple but different
> port numbers can be grouped together for IP layer processing, then split
> apart for L4.

To be fair you never showed us the numbers for DDOS traffic, and you did
not show us how typical TCP + netfilter modules kind of traffic would be
handled.

Show us real numbers, not synthetic ones, say when receiving traffic on
100,000 or more TCP sockets.

We also care about icache pressure, and GRO/TSO already provides
bundling where it is applicable, without adding insane complexity in the
stacks.

Just look at how complex the software fallbacks for GSO/checksumming
are, how many bugs we had to fix... And this is only at the edge of our
stack.
