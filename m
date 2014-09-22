From: Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>
Subject: Re: [patch net-next v2 8/9] switchdev: introduce Netlink
	API
Date: Mon, 22 Sep 2014 07:48:31 -0400
Message-ID: <54200C8F.2040501@mojatatu.com>
References: <1411134590-4586-9-git-send-email-jiri@resnulli.us>
 <541C4AFC.8060500@mojatatu.com> <20140919154946.GH1980@nanopsycho.orion>
 <541C6E6D.9000109@mojatatu.com> <541CAA3C.5080105@intel.com>
 <541CAB9A.3040100@mojatatu.com> <20140920081702.GF1821@nanopsycho.orion>
 <541D54BA.6070709@mojatatu.com> <20140920110121.GB29419@casper.infradead.org>
 <541D65CE.7080108@mojatatu.com> <20140922075337.GA1828@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: ryazanov.s.a-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
 John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Neil.Jerram-QnUH15yq9NYqDJ6do+/SaQ@public.gmane.org,
 edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org, dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org,
 f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, ronye-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
 ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org, buytenh-OLH4Qvv75CYX/NnBR394Jw@public.gmane.org,
 alexander.h.duyck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, simon.horman-wFxRvT7yatFl57MIdRCFDg@public.gmane.org,
 roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org, aviadr-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org,
 vyasevic-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org, dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org,
 davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20140922075337.GA1828-6KJVSR23iU488b5SBfVpbw@public.gmane.org>
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

On 09/22/14 03:53, Jiri Pirko wrote:

> Jamal, would you please give us some examples on how to use tc to work
> with flows? I have a feeling that you see something other people does not.

I will be a little verbose so as to avoid knowledge assumption.

Lets talk about tc classifier/action subsystem because that is what
would take advantage of flows. We could also talk about qdiscs i.e
schedulers and queue objects because the two are often related
(the default classification action is "classid" which typically
maps to a queue class).

tc classification/action subsystem allows you to specify arbitrary
classifiers and actions.
You can then specify (using a precise BNF grammar) how filters and
actions are to be related.
Look at iproute2/f_*.c to see the currently defined ones.

Each classifier has a name/id and attributes/options specific to
itself. Classifiers dont necessarily have to filter on packet
headers; they could filter on metadata for example.
Each classifier running in software may be offloaded. I think that
simple model would allow usable tools.
The classifier you have defined currently in your patches could
be realized via the u32 classifier but i think that would
require knowledge of u32. So for usability reasons I would
suggest to write a brand new classifier. For lack of a better
name, lets call it "multi-tuple classifier".
I would expect this classifier to be usable in software tc as
well without necessarily being offloaded.

There are two important details to note:
1) many different types of classifiers exist. This would very
likely depend on hardware implementation. It is academic bullshit
(i.e not pragmatic) to claim all hardware offload can use the
same classification language. As i was telling Thomas
I dont see why one wouldnt offload the defined bpf classifier.
 From an API level, this means your ->flow_add/del/get would have
to support ability to define different classifiers.

2) Each classifier will have different semantics.
 From a device API level this means you have to allow the different
classifiers to pass attributes specific to them. This means
each classifier may override the ops(). I am indifferent how
it is achieved. So while you could pass one big structure
such as your flow struct, one should be able to do u32
kind of semantics.

We also need to discover which device supports which classifiers
and what constraints exist in the hardware implementation exist
(we can talk about that because it is important). Example
if one supports u32, how many u32 rules can be offloaded etc.

As to how it is to be implemented:
I like the semantics of the current bridge code. I have always
wondered why we didnt use that scheme for offloading qdiscs.
Each device supporting FDB offload has an ->fdb_add/del/get
(dont quote me on the naming). User space describes what
it wants. If something is to be offloaded we already know the
netdev the user is pointing to. We invoke the appropriate
->flow() calls with appropriately cooked structures.
I am not sure i like that we pass the netlink structure as Scott
often seems to point to; i think that passing the internal
structure we would install in s/ware may be the better approach
since:
a) we would need to parse the data anyways for validation etc
b) each hardware offload will likely need to translate further in
internal format
c)we have well defined mapping between user and offload,
the generic structure will be very close to hardware.
note: that is what the fdb offload does.

Note: I described this using tc, but i dont see why nftable
couldnt follow the same approach. My angle is that we dont
impede other users by over-focussing on ovs and whatever
other things that surround it.
cheers,
jamal
