From: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
Subject: Re: [patch net-next 01/13] openvswitch: split flow
 structures into ovs specific and generic ones
Date: Thu, 4 Sep 2014 14:25:07 +0200
Message-ID: <20140904122507.GE1867@nanopsycho.lan>
References: <1409736300-12303-1-git-send-email-jiri@resnulli.us>
 <1409736300-12303-2-git-send-email-jiri@resnulli.us>
 <540731B9.4010603@gmail.com>
 <CALnjE+rk26Om1O5_Q=8tn7eAyh4Ywen-1+UD_nCVj_geZY1HuQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: ryazanov.s.a-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Rony Efraim <ronye-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
 jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, Neil.Jerram-QnUH15yq9NYqDJ6do+/SaQ@public.gmane.org,
 Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org,
 "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>, nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org,
 f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, John Fastabend <john.fastabend-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
 jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
 Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>, buytenh-OLH4Qvv75CYX/NnBR394Jw@public.gmane.org,
 roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org, jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org, aviadr-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
 Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>, vyasevic-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
 nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
 Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org,
 David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Pravin Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CALnjE+rk26Om1O5_Q=8tn7eAyh4Ywen-1+UD_nCVj_geZY1HuQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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

Wed, Sep 03, 2014 at 08:42:18PM CEST, pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org wrote:
>On Wed, Sep 3, 2014 at 8:20 AM, John Fastabend <john.fastabend-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>> On 09/03/2014 02:24 AM, Jiri Pirko wrote:
>>>
>>> After this, flow related structures can be used in other code.
>>>
>>> Signed-off-by: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
>>> ---
>>
>>
>> Hi Jiri,
>>
>> As I indicated before I'm looking into integrating this with some
>> hardware here. Progress is a bit slow but starting to look at it.The
>> i40e/ixgbe driver being one open source example with very limited
>> support for tables, flow matches, etc. And then a closed source driver
>> with much more flexibility. What I don't have is a middle of the road
>> switch to work with something better then a host nic but not as
>> flexible as a TOR.
>>
>> Couple questions my assumption here is I can extend the flow_key
>> as needed to support additional match criteria my hardware has.
>> I scanned the ./net/openvswitch source and I didn't catch any
>> place that would break but might need to take a closer look.
>> Similarly the actions set will need to be extended. For example
>> if I want to use this with i40e a OVS_ACTION_ATTR_QUEUE could
>> be used to steer packets to the queue. With this in mind we
>> will want a follow up patch to rename OVS_ACTION_ATTR_* to
>> FLOW_ACTION_ATTR_*
>>
>
>struct sw_flow_key is internal structure of OVS, it is designed to
>have better flow-table performance. By adding hw specific fields in
>sw_flow_key, it increase flow-key size and that has negative impact on
>OVS software switching performance. Therefore it is better not to
>share this internal structure with driver interface.

Ok. I will split this leaving the sw_flow_key into ovs and introducing
new one. Thanks.

>
>Thanks.
>
>> Also I have some filters that can match on offset/length/mask
>> tuples. As far as I can tell this is going to have to be yet
>> another interface? Or would it be worth the effort to define
>> the flow key more generically. My initial guess is I'll just
>> write a separate interface. I think this is what Jamal referred
>> to as another "classifier".
>>
>> Thanks,
>> John
>>
>> [...]
>>
>>
>>> +
>>> +struct sw_flow_key_ipv4_tunnel {
>>> +       __be64 tun_id;
>>> +       __be32 ipv4_src;
>>> +       __be32 ipv4_dst;
>>> +       __be16 tun_flags;
>>> +       u8   ipv4_tos;
>>> +       u8   ipv4_ttl;
>>> +};
>>> +
>>> +struct sw_flow_key {
>>> +       struct sw_flow_key_ipv4_tunnel tun_key;  /* Encapsulating tunnel
>>> key. */
>>> +       struct {
>>> +               u32     priority;       /* Packet QoS priority. */
>>> +               u32     skb_mark;       /* SKB mark. */
>>> +               u16     in_port;        /* Input switch port (or
>>> DP_MAX_PORTS). */
>>> +       } __packed phy; /* Safe when right after 'tun_key'. */
>>> +       struct {
>>> +               u8     src[ETH_ALEN];   /* Ethernet source address. */
>>> +               u8     dst[ETH_ALEN];   /* Ethernet destination address.
>>> */
>>> +               __be16 tci;             /* 0 if no VLAN, VLAN_TAG_PRESENT
>>> set otherwise. */
>>> +               __be16 type;            /* Ethernet frame type. */
>>> +       } eth;
>>> +       struct {
>>> +               u8     proto;           /* IP protocol or lower 8 bits of
>>> ARP opcode. */
>>> +               u8     tos;             /* IP ToS. */
>>> +               u8     ttl;             /* IP TTL/hop limit. */
>>> +               u8     frag;            /* One of OVS_FRAG_TYPE_*. */
>>> +       } ip;
>>> +       struct {
>>> +               __be16 src;             /* TCP/UDP/SCTP source port. */
>>> +               __be16 dst;             /* TCP/UDP/SCTP destination port.
>>> */
>>> +               __be16 flags;           /* TCP flags. */
>>> +       } tp;
>>> +       union {
>>> +               struct {
>>> +                       struct {
>>> +                               __be32 src;     /* IP source address. */
>>> +                               __be32 dst;     /* IP destination address.
>>> */
>>> +                       } addr;
>>> +                       struct {
>>> +                               u8 sha[ETH_ALEN];       /* ARP source
>>> hardware address. */
>>> +                               u8 tha[ETH_ALEN];       /* ARP target
>>> hardware address. */
>>> +                       } arp;
>>> +               } ipv4;
>>> +               struct {
>>> +                       struct {
>>> +                               struct in6_addr src;    /* IPv6 source
>>> address. */
>>> +                               struct in6_addr dst;    /* IPv6
>>> destination address. */
>>> +                       } addr;
>>> +                       __be32 label;                   /* IPv6 flow
>>> label. */
>>> +                       struct {
>>> +                               struct in6_addr target; /* ND target
>>> address. */
>>> +                               u8 sll[ETH_ALEN];       /* ND source link
>>> layer address. */
>>> +                               u8 tll[ETH_ALEN];       /* ND target link
>>> layer address. */
>>> +                       } nd;
>>> +               } ipv6;
>>> +       };
>>> +} __aligned(BITS_PER_LONG/8); /* Ensure that we can do comparisons as
>>> longs. */
>>> +
>>> +struct sw_flow_key_range {
>>> +       unsigned short int start;
>>> +       unsigned short int end;
>>> +};
>>> +
>>> +struct sw_flow_mask {
>>> +       struct sw_flow_key_range range;
>>> +       struct sw_flow_key key;
>>> +};
>>> +
>>> +struct sw_flow_action {
>>> +};
>>> +
>>> +struct sw_flow_actions {
>>> +       unsigned count;
>>> +       struct sw_flow_action actions[0];
>>> +};
>>> +
>>> +struct sw_flow {
>>> +       struct sw_flow_key key;
>>> +       struct sw_flow_key unmasked_key;
>>> +       struct sw_flow_mask *mask;
>>> +       struct sw_flow_actions *actions;
>>> +};
>>> +
>>
>>
>>
>> --
>> John Fastabend         Intel Corporation
