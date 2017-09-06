From: Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>
Subject: Re: [PATCH net-next v6 3/3] openvswitch: enable NSH
	support
Date: Wed, 06 Sep 2017 10:03:29 +0200
Message-ID: <87o9qo9ru6.fsf@stressinduktion.org>
References: <1503670805-31051-1-git-send-email-yi.y.yang@intel.com>
	<1503670805-31051-4-git-send-email-yi.y.yang@intel.com>
	<87wp5l7560.fsf@stressinduktion.org>
	<20170904023831.GA68062@cran64.bj.intel.com>
	<87mv6abte5.fsf@stressinduktion.org>
	<20170905021112.GA86057@cran64.bj.intel.com>
	<87vakxsaj2.fsf@stressinduktion.org>
	<20170905113848.GC92895@cran64.bj.intel.com>
	<878thtmgra.fsf@stressinduktion.org>
	<20170906005359.GA103260@cran64.bj.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "e@erig.me" <e@erig.me>
To: "Yang\, Yi" <yi.y.yang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20170906005359.GA103260-re2EX8HDrk21gSHoDXDV2kEOCMrvLtNR@public.gmane.org> (Yi Yang's message
	of "Wed, 6 Sep 2017 08:53:59 +0800")
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

> On Tue, Sep 05, 2017 at 09:12:09PM +0800, Hannes Frederic Sowa wrote:
>> "Yang, Yi" <yi.y.yang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org> writes:
>> 
>> > We can change this later if we really find a better way to handle this
>> > because it isn't defined in include/uapi/linux/openvswitch.h, so I still
>> > have backdoor to do this if needed :-)
>> 
>> Sorry, I can't follow you.
>> 
>> It doesn't matter if something is defined in uapi headers, the
>> observable behavior matters. If you allow users to configure flows with
>> specific fields, it should not stop working at a future point in time.
>
> Anyway this can be changed if it is really needed, so far current way is
> the best one we can come up with, we would like to use it if you can
> have better proposal. We have explained repeatedly context headers must
> be matched and set, this is bottom line.

I understand that in the way you use those context fields you will have
to match on those. I understand that there is no way around that.

>> > For our sfc use case in Opendaylight, we use context[0] for tunnel ID,
>> > context[1] for destination IP for reverse RSP, they are used to match
>> > and set in OpenFlow table, you can't limit users to use them in such
>> > ways.
>> 
>> So in your specific case you expect the masks to be completely stable
>> because you defined a protocol on top of NSH, understood. And that is
>> stable accross all possible paths. Understood as well.
>> 
>> > If you check GENEVE implementation, tun_metadata* can be set or matched
>> > as any other match field.
>> 
>> Yes, I wrote that in my previous mail. I wonder why NSH context metadata
>> is not in tun_metadata as well?
>
> tun_metadata is tunnel metadata, GENEVE needs tunnel port, but NSH is
> not so, NSH can't directly use tun_metadata, for MD type 2, we need to a
> lot of rework on tun_metadata to make it shared between GENEVE and NSH,
> I don't think this can happen in near term. So tun_metadata isn't option
> for this now.

Sorry, I couldn't follow you. Why can't you store the context headers in
tun_metadata exactly?

[...]

Bye,
Hannes
