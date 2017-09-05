From: Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>
Subject: Re: [PATCH net-next v6 3/3] openvswitch: enable NSH
	support
Date: Tue, 05 Sep 2017 15:12:09 +0200
Message-ID: <878thtmgra.fsf@stressinduktion.org>
References: <1503670805-31051-1-git-send-email-yi.y.yang@intel.com>
	<1503670805-31051-4-git-send-email-yi.y.yang@intel.com>
	<87wp5l7560.fsf@stressinduktion.org>
	<20170904023831.GA68062@cran64.bj.intel.com>
	<87mv6abte5.fsf@stressinduktion.org>
	<20170905021112.GA86057@cran64.bj.intel.com>
	<87vakxsaj2.fsf@stressinduktion.org>
	<20170905113848.GC92895@cran64.bj.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "e@erig.me" <e@erig.me>
To: "Yang\, Yi" <yi.y.yang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20170905113848.GC92895-re2EX8HDrk21gSHoDXDV2kEOCMrvLtNR@public.gmane.org> (Yi Yang's message
	of "Tue, 5 Sep 2017 19:38:49 +0800")
List-Unsubscribe: <https://mail.openvswitch.org/mailman/options/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://mail.openvswitch.org/pipermail/ovs-dev/>
List-Post: <mailto:ovs-dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <https://mail.openvswitch.org/mailman/listinfo/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

"Yang, Yi" <yi.y.yang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org> writes:

> On Tue, Sep 05, 2017 at 12:30:09PM +0200, Hannes Frederic Sowa wrote:
>> "Yang, Yi" <yi.y.yang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org> writes:
>> 
>> > I'm not sure what new action you expect to bring here, I think group
>> > action is just for this, as you said it isn't only bound to NSH, you can
>> > start a new thread to discuss this. I don't think it is in scope of NSH.
>> 
>> It is in scope of this discussion as you will provide a user space API
>> that makes the NSH context fields accessible from user space in a
>> certain way. If you commit to this, there is no way going back.
>
> We can change this later if we really find a better way to handle this
> because it isn't defined in include/uapi/linux/openvswitch.h, so I still
> have backdoor to do this if needed :-)

Sorry, I can't follow you.

It doesn't matter if something is defined in uapi headers, the
observable behavior matters. If you allow users to configure flows with
specific fields, it should not stop working at a future point in time.

>> I haven't yet grasped the idea on how those fields will be used in OVS
>> besides load balancing. Even for load balancing the tunnel itself
>> (vxlan-gpe + UDP source port or ipv6 flowlabel) already provides enough
>> entropy to do per-flow load balancing. What else is needed?  Why a
>> context header for that? You just need multiple action chains and pick
>> one randomly.
>
> For our sfc use case in Opendaylight, we use context[0] for tunnel ID,
> context[1] for destination IP for reverse RSP, they are used to match
> and set in OpenFlow table, you can't limit users to use them in such
> ways.

So in your specific case you expect the masks to be completely stable
because you defined a protocol on top of NSH, understood. And that is
stable accross all possible paths. Understood as well.

> If you check GENEVE implementation, tun_metadata* can be set or matched
> as any other match field.

Yes, I wrote that in my previous mail. I wonder why NSH context metadata
is not in tun_metadata as well?

> Actually the most important information in NSH are just these context
> headers, you can't limit imagination of users by removing them from flow
> keys.
>
> My point is to bring miniflow into kernel data path to fix your concern,
> this will benefit your employer directly :-)

Okay, interesting. It will probably not help if you still have a hash of
a packet inside the flow table and use that for load balancing.

[...]

BTW I don't want to stop this patch, I am merely interested in how the
bigger picture will look like in the end.

Bye,
Hannes
