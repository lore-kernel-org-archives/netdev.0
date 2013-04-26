From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next 1/2] net: More fine-grained support
 for encapsulated GSO features
Date: Fri, 26 Apr 2013 16:03:21 -0700
Message-ID: <CAEP_g=_xZOjn6ByhM3sKw-f2Ui9kjnb1wUJ2EGBBg3GD5JnmLw@mail.gmail.com>
References: <1366683556-4956-1-git-send-email-horms@verge.net.au>
	<1366683556-4956-2-git-send-email-horms@verge.net.au>
	<alpine.LFD.2.02.1304231354440.5598@morpheus.jf.intel.com>
	<20130425073644.GC7936@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
	Alexander Duyck <alexander.h.duyck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	=?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Joseph Gasparakis <joseph.gasparakis-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20130425073644.GC7936-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 25, 2013 at 12:36 AM, Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org> wrote:
> On Tue, Apr 23, 2013 at 02:00:19PM -0700, Joseph Gasparakis wrote:
>> Any particular reason to introduce skb->encapsulation_features instead of
>> using the existing skb->encapsulation? Also I don't see it used in your
>> second patch either.
>
> My reasoning is that skb->encapsulation seems to alter the behaviour of
> many different locations and I'm not sure that any of them, other than the
> one in dev_hard_start_xmit() make sense for MPLS.

The problem is the meaning of skb->encapsulation isn't really defined
clearly and I'm certain that the current implementation is not going
to work in the future. Depending on your perspective, vlans, MPLS,
tunnels, etc. can all be considered forms of encapsulation but clearly
there are many NICs that have different capabilities across those. I
believe the intention here was really to describe L3 tunnels as
encapsulation, in which case MPLS really shouldn't be using this
mechanism at all.

Now there is some overlap, especially today since most currently
shipping silicon wasn't designed to support tunnels and so is using
some form of offset based offloads. In that case, all forms of
encapsulation are pretty similar. However, in the future that won't be
the case as support for specific protocols is implemented for higher
performance and richer support. When that happens, not only will MPLS
and tunnels have different capabilities but various forms tunnels
might as well.
