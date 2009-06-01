From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 1/4] net: skb_orphan on dev_hard_start_xmit
Date: Mon, 1 Jun 2009 21:57:28 +0930
Message-ID: <200906012157.29465.rusty@rustcorp.com.au>
References: <200905292344.56814.rusty@rustcorp.com.au>
	<4A1FFB04.30305@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: libertas-dev@lists.infradead.org, Dan Williams <dcbw@redhat.com>,
        netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
        Roland Dreier <rolandd@cisco.com>, Divy Le Ray <divy@chelsio.com>,
        Pavel Emelianov <xemul@openvz.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <4A1FFB04.30305@gmail.com>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/virtualization>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Sat, 30 May 2009 12:41:00 am Eric Dumazet wrote:
> Rusty Russell a =E9crit :
> > DaveM points out that there are advantages to doing it generally (it's
> > more likely to be on same CPU than after xmit), and I couldn't find
> > any new starvation issues in simple benchmarking here.
>
> If really no starvations are possible at all, I really wonder why some
> guys added memory accounting to UDP flows. Maybe they dont run "simple
> benchmarks" but real apps ? :)

Well, without any accounting at all you could use quite a lot of memory as =

there are many places packets can be queued.

> For TCP, I agree your patch is a huge benefit, since its paced by remote
> ACKS and window control

I doubt that.  There'll be some cache friendliness, but I'm not sure it'll =
be =

measurable, let alone "huge".  It's the win to drivers which don't have a =

timely and batching tx free mechanism which I aim for.

> , but an UDP sender will likely be able to saturate
> a link.

I couldn't see any difference in saturation here (with default scheduler an=
d an =

100MBit e1000e).  Two reasons come to mind: firstly, only the hardware queu=
e is =

unregulated: the tx queue is still accounted.  And when you add scheduling =
to =

the mix, I can't in practice cause starvation of other senders.

Hope that clarifies,
Rusty.
