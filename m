From: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Subject: Re: [PATCH net-next 1/2] net: More fine-grained support
 for encapsulated GSO features
Date: Fri, 3 May 2013 08:55:24 +0900
Message-ID: <20130502235524.GA16625@verge.net.au>
References: <20130425073644.GC7936@verge.net.au>
	<CAEP_g=_xZOjn6ByhM3sKw-f2Ui9kjnb1wUJ2EGBBg3GD5JnmLw@mail.gmail.com>
	<20130430032121.GC26726@verge.net.au>
	<CAEP_g=-9abqxGyox7s4jjzTdPFTXmnLU6gkq+ihGwXJg-NAdaA@mail.gmail.com>
	<20130501075029.GD27158@verge.net.au>
	<CAEP_g=8_W4Y7zEG2ANjSV91wC8-b+i5XcY-RDa6_w7nvuuHyUA@mail.gmail.com>
	<20130501225706.GC6517@verge.net.au>
	<CAEP_g=9jRXMZgm9DB=oz+-08d3dPCptB+VY86n2qtq0RhTooKg@mail.gmail.com>
	<20130502053144.GA19430@verge.net.au>
	<CAEP_g=_0cOnE1Bhm5PGPhPTBvBEjoN_+oS-zUeNBM4ZyoJe-yg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
	Alexander Duyck <alexander.h.duyck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Maciej =?utf-8?Q?=C5=BBenczykowski?= <maze-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Joseph Gasparakis <joseph.gasparakis-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAEP_g=_0cOnE1Bhm5PGPhPTBvBEjoN_+oS-zUeNBM4ZyoJe-yg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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

On Thu, May 02, 2013 at 09:53:25AM -0700, Jesse Gross wrote:
> On Wed, May 1, 2013 at 10:31 PM, Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org> wrote:
> > On Wed, May 01, 2013 at 09:53:42PM -0700, Jesse Gross wrote:
> >> On Wed, May 1, 2013 at 3:57 PM, Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org> wrote:
> >> > On Wed, May 01, 2013 at 11:16:40AM -0700, Jesse Gross wrote:
> >> >> On Wed, May 1, 2013 at 12:50 AM, Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org> wrote:
> >> >> > On Tue, Apr 30, 2013 at 09:19:51AM -0700, Jesse Gross wrote:
> >> >> >> On Mon, Apr 29, 2013 at 8:21 PM, Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org> wrote:
> >> >> >> > On Fri, Apr 26, 2013 at 04:03:21PM -0700, Jesse Gross wrote:
> >> >> >> >> On Thu, Apr 25, 2013 at 12:36 AM, Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org> wrote:
> >> >> >> >> > On Tue, Apr 23, 2013 at 02:00:19PM -0700, Joseph Gasparakis wrote:
> >> >> >> >> >> Any particular reason to introduce skb->encapsulation_features instead of
> >> >> >> >> >> using the existing skb->encapsulation? Also I don't see it used in your
> >> >> >> >> >> second patch either.
> >> >> >> >> >
> >> >> >> >> > My reasoning is that skb->encapsulation seems to alter the behaviour of
> >> >> >> >> > many different locations and I'm not sure that any of them, other than the
> >> >> >> >> > one in dev_hard_start_xmit() make sense for MPLS.
> >> >> >> >>
> >> >> >> >> The problem is the meaning of skb->encapsulation isn't really defined
> >> >> >> >> clearly and I'm certain that the current implementation is not going
> >> >> >> >> to work in the future. Depending on your perspective, vlans, MPLS,
> >> >> >> >> tunnels, etc. can all be considered forms of encapsulation but clearly
> >> >> >> >> there are many NICs that have different capabilities across those. I
> >> >> >> >> believe the intention here was really to describe L3 tunnels as
> >> >> >> >> encapsulation, in which case MPLS really shouldn't be using this
> >> >> >> >> mechanism at all.
> >> >> >> >>
> >> >> >> >> Now there is some overlap, especially today since most currently
> >> >> >> >> shipping silicon wasn't designed to support tunnels and so is using
> >> >> >> >> some form of offset based offloads. In that case, all forms of
> >> >> >> >> encapsulation are pretty similar. However, in the future that won't be
> >> >> >> >> the case as support for specific protocols is implemented for higher
> >> >> >> >> performance and richer support. When that happens, not only will MPLS
> >> >> >> >> and tunnels have different capabilities but various forms tunnels
> >> >> >> >> might as well.
> >> >> >> >
> >> >> >> > Wouldn't be possible to describe those differences using,
> >> >> >> > dev->hw_enc_features? I assumed that was its purpose.
> >> >> >>
> >> >> >> If there truly are differences between the offload capabilities of
> >> >> >> MPLS and L3 tunnels then no, it's not possible, because it's a single
> >> >> >> field. It's certainly not a valid assumption that a NIC that can do
> >> >> >> TSO over GRE can also do it over MPLS.
> >> >> >>
> >> >> >> However, it's unlikely that there are truly significant differences
> >> >> >> between various encapsulation formats on a per-feature basis. I think
> >> >> >> what we need to do is separate out the ability to understand the
> >> >> >> headers from the capabilities so you have two fields: header (none,
> >> >> >> VLAN, QinQ, MPLS, VXLAN, GRE, etc.) and feature (checksum, SG, TSO,
> >> >> >> etc.) rather than the product of each. Otherwise, we end up with a ton
> >> >> >> of different combinations.
> >> >> >
> >> >> > I'm not quite sure that I follow.
> >> >> >
> >> >> > Is your idea to replace skb->encapsulation (a single bit) with
> >> >> > a field that corresponds to the outer-most (encapsulation) header in use
> >> >> > and has bits for none, VLAN, QinQ, MPLS, VXLAN, GRE, etc...?
> >> >>
> >> >> No, I'm talking about netdev features. You can already tell the
> >> >> encapsulation type of a packet by looking at the EtherType.
> >> >
> >> > Now I am completely confused about what are the two fields that you
> >> > refer to in your previous email.
> >>
> >> I have always been referring to the netdev features for various
> >> protocol types. This is because considering MPLS as a form of
> >> encapsulation for the purpose of offloads buckets too many protocols
> >> into the same set and NICs will have varying features for those.
> >> Trying to avoid this by having a bit for offloadable encapsulations is
> >> just going to be very confusing and not very future proof.
> >>
> >> > In regards to looking ath the ethernet type:
> >> >
> >> > One of the tricky parts of MPLS is that the packet itself does not contain
> >> > the ethernet type or any other way of knowing the type of the inner-packet.
> >> > Information that is needed for GSO.
> >>
> >> I'm aware of that. However, you were referring to the type of
> >> encapsulation. It is easy to determine that a packet is MPLS.
> >>
> >> > My proposal to get around this is to leave skb->protocol as the
> >> > original, in the case we are interested in non-MPLS, ethernet type.
> >>
> >> At the very least, this is not consistent with how it is currently
> >> handled (for example, with VLANs) and seems difficult to do properly.
> >> However, I have not seen any further analysis since the last time that
> >> we discussed this.
> >
> > Unfortunately my efforts to solicit feedback from others regarding
> > that have not been successful.
> 
> Give me a break, Simon. These are your patches and therefore it is
> your responsibility to do the analysis. This has come up over and over
> again and I'm not happy about it.
> 
> Rather than trying to respond to me as quickly as possible, you need
> to slow down, take a step back, and think about the correct direction.
> Given that some of these patches have revision numbers in the 20s you
> have nothing to complain about as far as receiving help.
> 
> In order to assist you in this, I'm going to drop all of your pending
> patches from my queue and not respond to anything further from you
> until the merge window is open again.

I apologise, the comment I made above was unnecessary.

I accept your criticism in regards to responding to quickly.
