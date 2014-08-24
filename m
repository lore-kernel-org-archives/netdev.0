From: Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>
Subject: Re: [patch net-next RFC 10/12] openvswitch: add support
 for datapath hardware offload
Date: Sun, 24 Aug 2014 11:15:56 -0400
Message-ID: <53FA01AC.10507@mojatatu.com>
References: <1408637945-10390-1-git-send-email-jiri@resnulli.us>
 <1408637945-10390-11-git-send-email-jiri@resnulli.us>
 <53F79C54.5050701@gmail.com>
 <464DB0A8-0073-4CE0-9483-0F36B73A53A1@cumulusnetworks.com>
 <53F9459B.2070801@mojatatu.com> <20140824111218.GA32741@casper.infradead.org>
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
In-Reply-To: <20140824111218.GA32741-FZi0V3Vbi30CUdFEqe4BF2D2FQJk+8+b@public.gmane.org>
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

On 08/24/14 07:12, Thomas Graf wrote:
> On 08/23/14 at 09:53pm, Jamal Hadi Salim wrote:

>
> I get what you are saying but I don't see that to be the case here. I
> don't see how this series proposes the OVS case as *the* interface.

The focus of the patches is on offloading flows (uses the
ovs or shall i say the broadcom OF-DPA API, which is one
vendor's view of the world).

Yes, people are going to deploy more hardware which knows how to do
a lot of flows (but today that is in the tiny tiny minority)

I would have liked to see more focus on L2/3 as a first step because
they are more predominantly deployed than anything with flows. And
they are well understood from a functional perspective.
Then that would bring to the front API issues since you have
a large sample space of deployments and we can refactor as needed.
i.e
The hard part is dealing with 10 different chips which have a slightly
different meaning of (example) how to do L3 in their implementation.
I dont see such a focus in these patches because they start with a
premise "the world is about flows".

> It proposes *a* interface which in this case is flow based with mask
> support to accomodate the typical ntuple filter API in HW. OVS happens
> to be one of the easiest to use examples as a consumer because it
> already provides a flat flow representation.
>

In other words, there is a direct 1-1 map between this approach and OVS.
That is a contentious point.

> I thought this is exactly what is happening here. The flow key/mask
> based API as proposed focuses on basic forwarding for L2-L4.
>

Not at all.
I gave an example earlier with u32, but lets pick the other extreme
of well understood functions, say L3 (I could pick L2 as well).
This openflow api tries to describe different header
fields in the packet. That is not the challenge for such an
API. The challenge is dealing with the quarks.
Some chips implement FIB and NH conjoined; others implement
them separately.
I dont see how this is even being remotely touched on.


>
> Exactly and I never saw Jiri claim that swdev_flow_insert() would be
> the only offload capability exposed by the API. I see no reason why
> it could not also provide swdev_offset_match_insert() or
> swdev_ebpf_insert() for the 2*next generation HW. I don't think it
> makes sense to focus entirely on finding a single common denominator
> and channel everything through a single function to represent all the
> different generic and less generic offload capabilities. I believe
> that doing so will raise the minimal HW requirements barrier HW too
> much. I think we should start somewhere, learn and evolve.
>

You are asking me to go and add a new ndo() every time i have a new 
network function? That is not scalable. I have no problem with
the approach that was posted - I have a problem that it is it
focused on flows (and is lacking ability to specify different
classifiers). It should not be called xxx_flow_xxx


> So essentially what you are saying is that the tc interface
> (in particular cls and act) could be used as an API to achieve offloads.

I am pointing to it as an example of something that is *done right* in
terms of not picking a universal classifier. Something the current
OVS posted/used api lacks (and to be frank OF never cared about because
it had a niche use case; lets not make that niche use case the centre
of gravity).

> Yes! I thought this was very clear and a given. I don't think that it
> makes sense to force every offload API consumer through the tc interface
> though.

If you looked at all my presentations I have never laid such
claim but i have always said I want everything described in
iproute2 to work. I dont think anyone disagreed.
I dont expect tc to be used as *the interface*; but on the same
token i dont expect OVS to be used as *the interface*.
Lets start with hardware abstraction. Lets map to existing Linux APIs
and then see where some massaging maybe needed.

> This comes back to my statements in a previous email. I don't
> think we should require that all the offload decision complexity *has*
> to live in the kernel.

Agreed. Move policy decisions out of the kernel for one but also
any complex acrobatics as well that are use case specific.

> Quagga, nft, or OVS should be given an API to
> influence this more directly (with the hardware complexity properly
> abstracted). In-kernel users such as bridge, l3 (especially rules),
> and tc itself could be handled through a cls/act derived API internally.
>

This abstraction gives OVS 1-1 mapping which is something i object to.
You want to penalize me for the sake of getting the OVS api in place?
Beginning with flows and laying claim to that one would be able to
cover everything is non-starter.

>> Lets pick an example of the u32 classifier (or i could pick nftables).
>> Using your scheme i have to incur penalties to translating u32 to your
>> classifier and only achieve basic functionality; and now in addition
>> i cant do 90% of my u32 features. And u32 is very implementable
>> in hardware.
>
> I don't fully understand the last claim.


I will simplify:
You cant possibly do the u32 classifier completely using the posted
hard-coded 15 tuple classifier. It is an NP-complete problem.
There are *a lot* of use cases which can be specified by u32 that are
not possible to specify with the tuples the patches posted propose.
The reverse is not true. You can fully specify the OVS classifier
with u32.
So if you want to specify the closest to a universal grammar for
specifying a classifier - use u32 and create templates for your
classifier.
There are some cases where that approach doesnt make sense:
example if i wanted to specify a string classifier etc.
But if we are talking packet header classifier - it is flexible.
There are also good reasons to specify a universal 5 tuple classifier.
As there are good reasons to specify your latest OF classifier.
But that OF classifier being the starting point is not pragmatic.

Sorry -I cut the email a little because people with short attention span
are probably not following by this time.

I may be slower in responding since i will be offline.

cheers,
jamal
