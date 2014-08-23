From: John Fastabend <john.fastabend-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [patch net-next RFC 10/12] openvswitch: add support
 for datapath hardware offload
Date: Sat, 23 Aug 2014 10:09:13 -0700
Message-ID: <53F8CAB9.8080407@gmail.com>
References: <1408637945-10390-1-git-send-email-jiri@resnulli.us>
 <1408637945-10390-11-git-send-email-jiri@resnulli.us>
 <53F79C54.5050701@gmail.com>
 <464DB0A8-0073-4CE0-9483-0F36B73A53A1@cumulusnetworks.com>
 <20140823092458.GC1854@nanopsycho.orion>
 <20140823145126.GB24116@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; Format="flowed"
Content-Transfer-Encoding: quoted-printable
Cc: ryazanov.s.a-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
 Neil.Jerram-QnUH15yq9NYqDJ6do+/SaQ@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org,
 dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, ronye-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
 jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org,
 buytenh-OLH4Qvv75CYX/NnBR394Jw@public.gmane.org, Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>,
 roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org, jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org, aviadr-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
 nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org, vyasevic-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
 netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org, dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
 ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20140823145126.GB24116-FZi0V3Vbi30CUdFEqe4BF2D2FQJk+8+b@public.gmane.org>
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

On 08/23/2014 07:51 AM, Thomas Graf wrote:
> On 08/23/14 at 11:24am, Jiri Pirko wrote:
>> Sat, Aug 23, 2014 at 12:53:34AM CEST, sfeldma-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org wrote:
>>>
>>> On Aug 22, 2014, at 12:39 PM, John Fastabend <john.fastabend-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>=
 wrote:
>>>> - this requires OVS to be loaded to work. If all I want is
>>>>    direct access to the hardware flow tables requiring openvswitch.ko
>>>>    shouldn't be needed IMO. For example I may want to use the
>>>>    hardware flow tables with something not openvswitch and we
>>>>    shouldn't preclude that.
>>>>
>>>
>>> The intent is to use openvswitch.ko=92s struct sw_flow to program hardw=
are via the ndo_swdev_flow_* ops, but otherwise be independent of OVS.  So =
the upper layer of the driver is struct sw_flow and any module above the dr=
iver can construct a struct sw_flow and push it down via ndo_swdev_flow_*. =
 So your non-OVS use-case should be handled.  OVS is another use-case.  str=
uct sw_flow should not be OVS-aware, but rather a generic flow match/action=
 sufficient to offload the data plane to HW.
>>
>> Yes. I was thinking about simple Netlink API that would expose direct
>> sw_flow manipulation (ndo_swdev_flow_* wrapper) to userspace. I will
>> think abou that more and perhaps add it to my next patchset version.
>
> I agree that this might help to give a better API consumption example
> for everyone not familiar with OVS.

Yep and it solves one of my simple cases where I have macvlan configured
with SR-IOV or the l2-dfwd-offload bit set and want to push some basic
static ACLs into the flow table. If you have to bring the port into the
OVS framework I'm not sure how make this coexist.

>
>>>> - Also there is no programmatic way to learn which flows are
>>>>    in hardware and which in software. There is a pr_warn but
>>>>    that doesn't help when interacting with the hardware remotely.
>>>>    I need some mechanism to dump the set of hardware tables and
>>>>    the set of software tables.
>>>
>>> Agreed, we need a way to annotate which flows are installed hardware.
>>
>> Yes, we discussed that already. We need to make OVS daemon hw-offload
>> aware indicating which flow it want/prefers to be offloaded. This is I
>> believe easily extentable feature and can be added whenever the right
>> time is.
>
> I think the swdev flow API is good as-is. The bitmask specyfing the
> offload preference with all the granularity (offload-or-fail,
> try-to-offload, never-offload) needed can be added later, either in
> OVS only or in swdev itself.
>
> What is unclear in this patch is how OVS user space can know which
> flows are offloaded and which aren't. A status field would help here
> which indicates either: flow inserted and offloaded, flow inserted but
> not offloaded. Given that, the API consumer can easily keep track of
> which flows are currently offloaded.
>

Right. I think this is basically what Jiri and I discussed when he
originally posted the series. For my use cases this is one of the
more interesting pieces. If no one else is looking at it I can try
it on some of the already existing open source drivers that have some
very simple support for ingress flow tables read flow director.

> Also, I'm not sure whether flow expiration is something the API must
> take care of. The current proposal assumes that HW flows are only
> ever removed by the API itself. Could the switch CPU run code which
> removes flows as well? That would call for Netlink notifications.
> Not that it's needed at this stage of the code but maybe worth
> considerating for the API design.

I think this will be very useful when we get to a point where we
can use this on some of the switch silicon that supports bigger tables
with more capabilities. Like you say we probably don't need it in
the first draft but having a path to support it is needed.

>
>>>> - Simply duplicating the software flow/action into
>>>>    hardware may not optimally use the hardware tables. If I have
>>>>    a TCAM in hardware for instance. (This is how I read the patch
>>>>    let me know if I missed something)
>>>
>>> The hardware-specific driver is the right place to handle optimizing th=
e flow/action in hardware since only the driver can know the size/shape of =
the device.  struct sw_flow is a generic flow description; how (or if) a fl=
ow gets programmed into hardware must be handled in the swdev driver.  If t=
he device driver can=92t make the sw_flow fit into HW because of resource l=
imitations or the flow simply can=92t be represented in HW, then the flow i=
s SW only.
>>>
>>> In the rocker driver posted in this patch set, the steps are to parse t=
he struct sw_flow to figure out what type of flow match/action we=92re deal=
ing with (L2 or L3 or L4, ucast or mcast, ipv4 or ipv6, etc) and then insta=
ll the correct entries into the corresponding device tables within the cons=
traints of the device=92s pipeline.  Any optimizations, like coalescing HW =
entries, is something only the driver can do.
>
> The later examples definitely make sense and I'm not argueing against
> that. There is also a non hardware capabilities perspective that I
> would like to present:
>
> 1) TCAM capacity is limtied, we offload based on some priority assigned
> to flows.  Some are critical and need to be in HW, others are best effort,
> others never go into hardware. An API user will likely want to offload
> best-effort flows until some watermark is reached and then switch to
> critical flows only. The driver is not the right place for high level
> optimization like this. The kernel API might but doesn't really have to
> either because it would mean we need APIs to transfer all of the
> needed context for the decision in the kernel. It might be easier to
> expose the hardware context to user space instead and handle these
> kind of optimizations in something like Quagga.
>
> 2) There is definitely a desire to allow adapting the software flow table
> based on the hardware capabilities. Example, given a route like this:
>
>     20.1.0.0/16, mark=3D50, tos=3D0x12, actions: output:eth1
>
> The hardware can satisfy everything except the mark=3D50 match. Given a
> a blind 1:1 copy between hardware and software we cannot offload
> because a mach would be illegal. With the full context as available
> north of the API, this could be translated into something like this:
>
>    HW: 20.1.0.0/16, tos=3D0x12, actions: meta=3D1, output:cpu
>    SW: meta=3D1, mark=3D50, output:eth1
>
> This will allow for partial offloads to bypass expensive masked flow
> table lookups by converting them into efficient flat exact match
> tables, offload TC classifiers, nftables or even the existing L2 and
> L3 forwarding path.

Thanks. This is exactly what I was trying to hint at and why the
optimization can not be done in the driver. The driver shouldn't
have to know about the cost models of SW vs HW rules or how to
break up rules into sets of complimentary hw/sw rules.

the other thing I've been thinking about is how to handle hardware
with multiple flow tables. We could let the driver handle this
but if I ever want to employ a new optimization strategy then I
need to rewrite the driver. To me this looks a lot like policy
which should not be driven by the kernel. We can probably ignore
this case for the moment until we get some of the other things
addressed.

>
> In summary, I think the swdev API as proposed is a good start as the
> in-kernel flow abstraction is sufficient for many API users but we
> should consider enabling the model described above as well once we
> have the basic model put in place. I will be very interested in helping
> out on this for both existing classifiers and OVS flow tables.
>
>
>>>> - I need a way to specify put this flow/action in hardware,
>>>>    put this flow/action in software, or put this in both software
>>>>    and hardware.
>>>>
>>>
>>> This seems above the swdev layer.  In other words, don=92t call ndo_swd=
ev_flow_* if you don=92t want flow match/action install in HW.
>
> It can certainly be done northbound but this seems like a basic
> requirement and we might end up avoiding the code duplication and
> extending the API instead.
>

IMO I think extending the API is the easiest route but the best
way to resolve this is to try and write the code. I'll take a
stab at it next week.

by the way Jiri I think the patches are a great start.

Thanks,
John

-- =

John Fastabend         Intel Corporation
