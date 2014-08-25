From: Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>
Subject: Re: [patch net-next RFC 10/12] openvswitch: add support
 for datapath hardware offload
Date: Mon, 25 Aug 2014 12:48:43 -0400
Message-ID: <53FB68EB.9060308@mojatatu.com>
References: <1408637945-10390-1-git-send-email-jiri@resnulli.us>
 <1408637945-10390-11-git-send-email-jiri@resnulli.us>
 <53F79C54.5050701@gmail.com>
 <464DB0A8-0073-4CE0-9483-0F36B73A53A1@cumulusnetworks.com>
 <53F9459B.2070801@mojatatu.com> <20140824111218.GA32741@casper.infradead.org>
 <53FA01AC.10507@mojatatu.com> <20140825145449.GB30140@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: ryazanov.s.a-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, ronye-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
 john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, Neil.Jerram-QnUH15yq9NYqDJ6do+/SaQ@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
 andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org, dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
 John Fastabend <john.fastabend-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
 ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org, buytenh-OLH4Qvv75CYX/NnBR394Jw@public.gmane.org,
 Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>, roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org, aviadr-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
 nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org, vyasevic-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
 netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org, dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
 ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20140825145449.GB30140-FZi0V3Vbi30CUdFEqe4BF2D2FQJk+8+b@public.gmane.org>
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

On 08/25/14 10:54, Thomas Graf wrote:
> On 08/24/14 at 11:15am, Jamal Hadi Salim wrote:

> Let's keep vendors out of this discussion.

The API is from a vendor. It is clearly labelled as an OF API.
It covers well abstracting that vendors SDK to enable OF. That
is relevant info.
If it covers all other vendors (which is where
the quark handling comes in), I will be fine with it.
I dont believe it does.

> That is simply not the case. The fact that John is using this model
> to replace the flow director ioctl API should prove this.

depends what NIC classifier John is mapping to. The Intels have
about 4-5 different types of classifier on different hardware
with different interfaces.
If it is a "flow type" - yes. I think you could wing-in the
RSS(and somehow announce you cant handle UDP). You may be able
to tie in RSS.
I am not sure about VMDQ; neither am i sure about what happens
when you need to deal with a combination of 2 or more classifiers
which i believe is part of the lookups in such hardware.
So that aside:
If you are telling me John is going to also map the L2 fdb here we are
going to have a strong disagreement.
And back to my earlier arguement:
allow for multiple classifiers to be expressed not THE ONE.
If i wanted to support CLASSIFIER_RSS from tc i could write one
and i can use tc to configure it. Or i could write one for nftables.
In general i probably should be able to wing it with some small
acrobatics.


> There is not a single bit specific to OpenFlow and there is absolutely
> no awareness of OF within the kernel in OVS.
>

The API is for OF support in a vendor ASIC.

>> fields in the packet. That is not the challenge for such an
>> API. The challenge is dealing with the quarks.
>> Some chips implement FIB and NH conjoined; others implement
>> them separately.
>> I dont see how this is even being remotely touched on.
>
> First of all, that sounds like exactly like something that should
> be handled in the driver specific portion of the API. Secondly,
> can you provide additional information on these specific pieces of
> hardware so we take it into account?
>

I gave a simple example.
There are a hell more quarks than that.
There are cases where there are multiple tables in terms of net masks
etc.
Yes, this should be handled in the driver. The input is the route
message we already specify and not some XXX_Flow_XXx struct.


> Realistically there will only be a handful, maybe something
> like:
>
> flow_insert / flow_remove
> p4_add / p4_remove
> [...]
>
> Maybe you can share some information the specific API you have
> in mind?
>

I would be tagging along with you guys for flows if you:
a) allow for different classifiers. This allows me to implement
u32 and offload it.
b) different actions (I think this part is not controversial, you
seem to be having it already).
c) stay out of L2/3. We know how to do this already. We have
representative data structures that *completely* define those.


> Agreed, I don't think anybody expects anything else.
>

I understand intent may be that. That is not the reality
when you start at OF-DPA as the api.


>> Lets start with hardware abstraction. Lets map to existing Linux APIs
>> and then see where some massaging maybe needed.
>
> That's what's being done. HW offload is being mapped to OVS and
> to an existing ioctl interface. Those are existing Linux APIs.
> Can you explain why swdev as proposed is not suitable for the
> other existing Linux APIs? They don't *have* to use the flow_insert(),
> they are free to exted the API to represent more generic programmable
> hardware.
>

I would like XXX_flow_XXX to allow for multiple types of classifiers.
nftables may express one and the driver which is capable offload it.

>> This abstraction gives OVS 1-1 mapping which is something i object to.
>> You want to penalize me for the sake of getting the OVS api in place?
>
> I don't understand this.
>

Refer to my comments earlier.

>> Beginning with flows and laying claim to that one would be able to
>> cover everything is non-starter.
>
> Nobody claims that. In fact, I'm very interested in seeing the API
> extended for non flow based models. I'm actually convinced that flow
> based models are not the ultimate answers on HW level but a vast majority
> of hardware understands some form of protocol aware exact match or
> wildcard filters of limited capacity. This category of hardware is
> being addressed with the flow_insert() API.
>

And make that also take input the classifier type.


>> There are some cases where that approach doesnt make sense:
>> example if i wanted to specify a string classifier etc.
>> But if we are talking packet header classifier - it is flexible.
>> There are also good reasons to specify a universal 5 tuple classifier.
>> As there are good reasons to specify your latest OF classifier.
>> But that OF classifier being the starting point is not pragmatic.
>
> So you agree that at least on the driver level some form of ntuple
> awareness must be given because the hardware has limited capabilities.

Yes, there is a classifier *type* where the 15 tuples makes sense.

> This is exactly what flow_insert() is, it is a generic ntuple
> classifier which can implement a subset of the 15 tuple in HW. So
> instead of adding a separate NDO for each fixed tuple, a generic
> NDO can handle the different levels of offloads. Very similar to how
> the xmit to the NIC can handle various protocol offloads already.
>
> What is being proposed is a generic ntuple with masking support to
> describe filtering needs. What is missing is a capabilities reporting
> channel so API users can know in advance what is supported to
> implement partial offloads.
>


The 15 tuple itself needs to be one-of several classifiers.
Creating a univesal classifier is problematic. Look at tc classifier
approach (which i know you understand well).

Sorry -I am on time constraint and may not be as responsive.

cheers,
jamal
