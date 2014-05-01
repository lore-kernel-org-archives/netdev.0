From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v2.56] datapath: Add basic MPLS support to
	kernel
Date: Thu, 1 May 2014 09:45:12 -0700
Message-ID: <CAEP_g=-rBXBJ4-CMRuPTxGnrqT-0PNMttvA5_HdugeM5to5Cew@mail.gmail.com>
References: <20140424232441.GA6282@verge.net.au>
 <20140425080639.DDFA371E74@kuma.localdomain>
 <CAEP_g=8y=jXukP=a2xyk4XMTrBLYWPQOgbTO_h8LE_mVMB9tFQ@mail.gmail.com>
 <20140428070012.GB21494@verge.net.au>
 <CAEP_g=-p1Zrs7ETjRrSLK+ug0Y7tbsF5U77K29tYyMTDk_0b4Q@mail.gmail.com>
 <20140429001317.GB31083@verge.net.au>
 <CAEP_g=8Or4axD_1Ztuc8+LHVZUKs6W0bsfNQxOHzGGENS0br-w@mail.gmail.com>
 <20140430055807.GA8246@verge.net.au>
 <CAEP_g=-qKYW+VXQ7DDuPbFamKa-wpHUcRdVOTNyutNTdaH-vLw@mail.gmail.com>
 <20140501085442.GA20410@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
 netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, YAMAMOTO Takashi <yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>,
 ravi kerur <rkerur-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20140501085442.GA20410-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

On Thu, May 1, 2014 at 1:54 AM, Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org> wrote:
> On Wed, Apr 30, 2014 at 03:56:44PM -0700, Jesse Gross wrote:
>> On Tue, Apr 29, 2014 at 10:58 PM, Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org> wrote:
>> > On Tue, Apr 29, 2014 at 11:41:57AM -0700, Jesse Gross wrote:
>> >> On Mon, Apr 28, 2014 at 5:13 PM, Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org> wrote:
>> >> > On Mon, Apr 28, 2014 at 02:37:47PM -0700, Jesse Gross wrote:
>> >> >> On Mon, Apr 28, 2014 at 12:00 AM, Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org> wrote:
>> >> >> > On Fri, Apr 25, 2014 at 12:57:20PM -0700, Jesse Gross wrote:
>> >> >> >> On Fri, Apr 25, 2014 at 1:06 AM, YAMAMOTO Takashi
>> >> >> >> <yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org> wrote:
>> >> >> >> >> On Thu, Apr 24, 2014 at 05:57:29PM +0900, YAMAMOTO Takashi wrote:
>> >> >> >> >>> hi,
>> >> >> >> >>>
>> >> >> >> >>> > + * Due to the sample action there may be multiple possible eth types.
>> >> >> >> >>> > + * In order to correctly validate actions all possible types are tracked
>> >> >> >> >>> > + * and verified. This is done using struct eth_types.
>> >> >> >> >>>
>> >> >> >> >>> is there any real-world use cases of these actions inside a sample?
>> >> >> >> >>> otherwise, how about just rejecting such combinations?
>> >> >> >> >>> it doesn't seem to worth the code complexity to me.
>> >> >> >> >>> (sorry if it has been already discussed.  it's the first time for me
>> >> >> >> >>> to seriously read this long-lived patch.)
>> >> >> >> >>
>> >> >> >> >> Good point, the code is rather complex.
>> >> >> >> >>
>> >> >> >> >> My understanding is that it comes into effect in the case
>> >> >> >> >> of sflow or ipfix being configured on the bridge. I tend
>> >> >> >> >> to think these are real-world use-cases, though that thinking
>> >> >> >> >> is by no means fixed.
>> >> >> >> >>
>> >> >> >> >> My reading of the code is that in the case of sflow and ipfix a single
>> >> >> >> >> sample rule appears at the beginning of the flow. And that it may be
>> >> >> >> >> possible to replace the code that you are referring to with something
>> >> >> >> >> simpler to handle these cases.
>> >> >> >> >
>> >> >> >> > it seems that they put only a userland action inside a sample.
>> >> >> >> > it's what i expected from its name "sample".
>> >> >> >>
>> >> >> >> Yes, that's the only current use case. In theory, this could be used
>> >> >> >> more generally although nothing has come up yet.
>> >> >> >>
>> >> >> >> In retrospect, I regret the design of the sample action - not the part
>> >> >> >> that allows it to handle different actions but the fact that the
>> >> >> >> results can affect things outside of the sample action list. I think
>> >> >> >> that if we had made it more like a subroutine then that would have
>> >> >> >> retained all of the functionality but none of the complexity here.
>> >> >> >> Perhaps if we can find a clean way to restructure it without breaking
>> >> >> >> compatibility then that would simplify the validation here.
>> >> >> >
>> >> >> > I have not thought deeply about this but it seems to me that it should be
>> >> >> > easy enough to provide compatibility for a new user-space to work with both
>> >> >> > new and old datapaths.  But it is not clear to me how to achieve the
>> >> >> > reverse: allowing a new datapath to work with both new and old user-spaces.
>> >> >> > I assume that we care about such compatibility.
>> >> >>
>> >> >> Generally, I would say yes although there is potentially some room for
>> >> >> debate here. No version of OVS userspace has ever put an action other
>> >> >> than userspace in the sample field. I know that other people have
>> >> >> talked about writing different userspaces that run on the OVS kernel
>> >> >> module but I highly doubt that they use this action or would do so
>> >> >> differently. I can't prove that but it might be OK to bite the bullet.
>> >> >
>> >> > I am also concerned about the sample() action which is exposed via OpenFlow
>> >> > (as a Nicira extension) and in turn ovs-ofctl.  Thus it seems to me that
>> >> > there could be users adding flows with sample actions whose behaviour would
>> >> > either no longer be supported or would be changed.  But I believe that we
>> >> > should reason about this case the same way that you reason about alternate
>> >> > user-spaces above.
>> >>
>> >> The sample action exposed through OpenFlow is a little different. It
>> >> allows you to specify where in the action list to do sampling but it
>> >> doesn't allow arbitrary actions to be embedded. As a result, it still
>> >> always embeds a userspace action, which should be safe because it is
>> >> idempotent.
>> >
>> > Thanks, that nicely removes my concern.
>> >
>> >> > Perhaps a way forward would be (for me) to come up with a prototype to
>> >> > alter the sample action. And we can see how clean it is (or could be) and
>> >> > what it buys us.
>> >> >
>> >> > It seems that the motivation for this change is is twofold: To contain the
>> >> > sample action in the hope of making it easier to deal with in the future
>> >> > and; to avoid some rather complex verification code introduced in the MPLS
>> >> > datapath patch. And I think it would be good to keep that in mind when
>> >> > assessing any prototype code.
>> >>
>> >> That sounds reasonable to me.
>> >
>> > I have come up with the following.
>> >
>> > In terms of gains, using this approach I have reduced the size of MPLS
>> > datapath patch by about 170 lines by replacing the complex logic that
>> > Yamamoto-san questioned with a simple verification of the current ethernet
>> > type (which may be changed by MPLS action).
>> >
>> >
>> > [PATCH/RFC] Sample action without side effects
>> >
>> > The sample action is rather generic, allowing arbitrary actions to be
>> > executed based on a probability. However its use, within the Open vSwitch
>> > code-base is limited: only a single user-space action is ever nested.
>> >
>> > A consequence of the current implementation of sample actions is that
>> > depending on weather the sample action executed (due to its probability)
>> > any side-effects of nested actions may or may not be present before
>> > executing subsequent actions.  This has the potential to complicate
>> > verification of valid actions by the (kernel) datapath. And indeed adding
>> > support for push and pop MPLS actions inside sample actions is one case
>> > where such case.
>> >
>> > In order to allow all supported actions to be continue to be nested
>> > inside sample actions without the potential need for complex verification
>> > code this patch changes the implementation of the sample action in the
>> > kernel datapath so that sample actions are more like a function call
>> > and any side effects of nested actions are not present when executing
>> > subsequent actions.
>> >
>> > With the above in mind the motivation for this change is twofold:
>> >
>> > * To contain side-effects the sample action in the hope of making it
>> >   easier to deal with in the future and;
>> > * To avoid some rather complex verification code introduced in the MPLS
>> >   datapath patch.
>> >
>> > Some notes about the implementation:
>> >
>> > * The OVS_SAMPLE_ATTR_FLAGS portion of this patch, which contributes to a
>> >   good portion of the size of the patch is intended to prevent any users
>> >   that were relying on side effects from sample actions from being silently
>> >   broken.
>> >
>> >   Any rule that includes a sample action with nested actions that
>> >   may have side effects (e.g. set, push/pop VLAN) will be rejected
>> >   unless OVS_SAMPLE_ATTR_FLAGS is present and its
>> >   OVS_SAMPLE_FLAG_SIDE_EFFECTS bit is set.
>> >
>> >   Thus users that were relying on side effects will experience rules
>> >   being rejected by the datapath. Rather than being silently handled
>> >   a different way.
>> >
>> >   It seems to me that it is rather unlikely that such users exist.
>> >   And thus it seems reasonable to me to remove the OVS_SAMPLE_ATTR_FLAGS
>> >   portion of this patch.
>> >
>> > * It is my understanding that the only user of the user-space datapath is
>> >   ovs-vswitchd.
>> >
>> >   As ovs-vswitchd never adds rules to the datapath that have sample actions
>> >   with nested actions with side effects I have not updated the user-space
>> >   datapath other than to call OVS_NOT_REACHED() if a sample action includes
>> >   the new OVS_SAMPLE_ATTR_FLAGS attribute. Primarily to make the
>> >   compiler happy about all values of the ovs_sample_attr enumeration
>> >   being handled by the case statement where that code resides.
>> >
>> >   My reasoning is follows:
>> >
>> >   + If the user-space datapath executes a sample action with nested
>> >     actions with side effects then it will be done so in the old way.
>> >     That is differently to the kernel datapath. But this will never happen
>> >     because ovs-vswitchd never creates such an action.
>> >
>> >   + If the OVS_SAMPLE_ATTR_FLAGS attribute is present when executing a
>> >     sample action in the user-space datapath then ovs-vswtichd will abort. But
>> >     again this will never happen because ovs-vswitchd never creates such
>> >     an action.
>> >
>> > Signed-off-by: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
>>
>> I'm mostly OK with this, although I think that the side effects
>> checking is probably not really worth the extra complexity given the
>> probably that it will ever get hit. Without that the patch becomes
>> quite short.
>
> Do mean the OVS_SAMPLE_ATTR_FLAGS portion as well as the side effects
> checking in the datapath action validation code?

Yes.

> I'm happy to remove all of that if you are happy with that approach.
> I agree it would make the patch nice and short.

I think it's pretty safe, so it would be nice to avoid introducing the
extra complexity.

>> The other thing that comes to mind is if there is a way to better
>> avoid cloning the skb. With recirculation, the action generally comes
>> as the last in the list and so the last_action check is quite
>> effective. However, with sampling it's always at the beginning and
>> never actually makes any changes to the packet so it's not really
>> useful work.
>
> I will give some thought to that.
>
> One, not very well developed, idea I have is to clone the skb
> action during execution of the sample action if a nested action may
> cause side effects. I'm entirely unsure how cleanly this could
> be implemented.

I had this thought as well. I guess it's probably OK to special case
for the userspace action since it is by far the common case and is
transparent to the rest of the system as an optimization.

I agree that it could be a little messy to look inside the attribute
but maybe we can encapsulate it somehow in the sample function.

>> Finally, I wonder if there is a way to merge the logic for keep_skb
>> and the checks for recirculation/sampling. It's gotten somewhat
>> complicated because there are all somewhat linked but different.
>
> I agree that would be nice. I think the exact details will
> depend on how skb clone avoidance is handled.

I agree.
