From: Roopa Prabhu <roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>
Subject: Re: [patch net-next RFC 10/12] openvswitch: add support
 for datapath hardware offload
Date: Tue, 26 Aug 2014 06:50:21 -0700
Message-ID: <53FC909D.8090000@cumulusnetworks.com>
References: <53F79C54.5050701@gmail.com>
 <464DB0A8-0073-4CE0-9483-0F36B73A53A1@cumulusnetworks.com>
 <53F9459B.2070801@mojatatu.com> <20140824111218.GA32741@casper.infradead.org>
 <53FA01AC.10507@mojatatu.com>
 <A67C7591-19BF-4431-9119-F61361F5E618@cumulusnetworks.com>
 <53FAA2A2.7070801@gmail.com> <53FB3FD5.2030905@mojatatu.com>
 <20140825141754.GA30140@casper.infradead.org> <53FB6122.2040901@mojatatu.com>
 <20140825225057.GD30140@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: ryazanov.s.a-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, ronye-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
 john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, Neil.Jerram-QnUH15yq9NYqDJ6do+/SaQ@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
 Andy Gospodarek <andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org>, dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org,
 f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Shrijeet Mukherjee <shm-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>,
 John Fastabend <john.fastabend-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
 ogerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org, buytenh-OLH4Qvv75CYX/NnBR394Jw@public.gmane.org,
 Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>, Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
 aviadr-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org, vyasevic-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
 Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org, dborkman <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
 ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20140825225057.GD30140-FZi0V3Vbi30CUdFEqe4BF2D2FQJk+8+b@public.gmane.org>
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

On 8/25/14, 3:50 PM, Thomas Graf wrote:
> On 08/25/14 at 12:15pm, Jamal Hadi Salim wrote:
>> On 08/25/14 10:17, Thomas Graf wrote:
>>> On 08/25/14 at 09:53am, Jamal Hadi Salim wrote:
>>> fdb_add() *is* flow based. At least in my understanding, the whole
>>> point here is to extend the idea of fdb_add() and make it understand
>>> L2-L4 in a more generic way for the most common protocols.
>>>
>>> The reason fdb_add() is not reused is because it is Netlink specific
>>> and only suitable for User -> HW offload. Kernel -> HW offload is
>>> technically possible but not clean.
>>>
>> I dont think we have a problem handling any of this today.
> Yes we do. It's restricted to L2 and we can't extend it easily
> because it is based on NDA_*. The use of Netlink makes in-kernel
> usage a pain. To me this is the sole reason for not using fdb_add()
> in the first place. It seems absolutely clear though that fdb_add()
> should be removed after the more generic ndo is in place providing
> a superset of what fdb_add() can do today.
>
>> This is where our (shall i say strong) disagreement is.
>> I think you will find it non-trivial to show me how you can
>> actually take the simple L2 bridge and map it to a "flow".
>> Since your starting point is "everything can be represented via a flow
>> and some table" - we are at a crosspath.
> OK, let me do the convertion for you:
>
> NDA_DST		unused
> NDA_LLADDR	sw_flow_key.eth.dst
> NDA_CACHEINFO	unused
> NDA_PROBES	unused
> NDA_VLAN	sw_flow_key.eth.tci
> NDA_PORT	unused
> NDA_VNI		sw_flow_key.tun_key.tun_id
> NDA_IFINDEX	sw_flow_key.phys.in_port
> NDA_MASTER	unused
>
>> The tc filter API seems to be doing just that.
>> You have different types of classifiers - the h/w may not be able
>> to support some classifier types - but that is a capability discovery
>> challenge.
> Agreed but tc is only one out of many possible existing interfaces
> we have. macvtap (given we want to extend beyond L2), routing,
> OVS, bridge and eventually even things like a team device can and
> should make use of offloads.
>
>> I am saying two things:
>> 1) There are a few "fundamental" interfaces; L2 and L3 being some.
>> Add crypto offload and a few i mentioned in  my presentation. We
> Can you share that preso? I was not present.
>
>> know how to do those. example; there is nothing i cant do with
>> the rtmsg that is L3. or the fdb/port/vlan filter for L2.
>> This flow thing should stay out of those.
> Let me remind you about the name of the structure behind all L3
> forwarding decisions:
>
>          struct flowi4 {
> 		[...]
> 	}
>
> Adding a route means adding a flow. Can we please stop the flow
> bashing? The concept of a flow is very generic, well known and already
> very present in the kernel.
>
> The sw_flow_key proposed comes close to flowi4. Some fields are
> different. They can eventually get merged. The strict IPv4/IPv6
> separation is what makes it non obvious and probably why Jiri chose
> the OVS representation. If you say rtmsg is complete then that clearly
> is not the case. In particular VTEP fields, ARP, and TCP flags are
> clearly missing for many uses.
>
> Again, I'm not saying flow is the ultimate answer to everything. It
> is not. But a lot of hardware out there is aware of flows in combination
> with some form of action execution. Non flow based hardware can have
> their own classifier.
>
>> 2) The flow thing should allow a variety of classifiers to be
>> handled. Again capability discovery would take care of differences.
> So you want the flow to represent something that is not a flow. Again,
> this comes back to the conversation in the other email. If this is
> all about having a single ndo I'm sure we can find common grounds on
> that.

 From what i understood (trying to summarize here for my own benefit):
the switchdev api currently under review proposes every switch asic 
offload abstraction as a flow.
It does not mandate this via code, however, there seems to be some 
discussion along those lines.

The switchdev api flow ndo's need to stay for switch asic drivers that 
support flows directly or
possibly want all their hw offload abstraction to be represented by the 
flow abstraction (openvswitch, the rocker dev ). The details of how the 
flow is mapped to hw lies in the corresponding switch driver code.

We think rtnetlink is the api to model switch asic hw tables.
We have a working model (Cumulus) that maps rtnetlink to switch
asic hw tables (via snooping rtnetlink msgs). This can be done by 
extending the switchdev api
with new ndo's for l2 and l3.

Example:
   new switchdev ndo's for fdb_add/fdb_del
   new switchdev ndo's for l3

Now we only need working patches that implement switchdev api ndo ops 
for l2/l3 (this is in the works).

As long as the current patches under review allow the extension of the 
api to cover non-flow based l2/l3 switch asic offloads, we might be good 
(?).

Thanks,
Roopa
