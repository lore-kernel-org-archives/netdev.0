From: John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next 4/4] net: Add Open vSwitch kernel
	components.
Date: Sat, 19 Nov 2011 20:55:59 -0800
Message-ID: <4EC8885F.3090607@intel.com>
References: <1321657938-21761-1-git-send-email-jesse@nicira.com>
	<1321657938-21761-5-git-send-email-jesse@nicira.com>
	<4EC73EDB.1010204@intel.com>
	<CAEP_g=8EpR_Z54ZvGZzFAeCVwVED3SUrddvLt7-aQ76Q919ekQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <CAEP_g=8EpR_Z54ZvGZzFAeCVwVED3SUrddvLt7-aQ76Q919ekQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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

On 11/19/2011 3:06 PM, Jesse Gross wrote:
> On Fri, Nov 18, 2011 at 9:30 PM, John Fastabend
> <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org> wrote:
>> On 11/18/2011 3:12 PM, Jesse Gross wrote:
>>> + */
>>> +enum ovs_frag_type {
>>> +       OVS_FRAG_TYPE_NONE,
>>> +       OVS_FRAG_TYPE_FIRST,
>>> +       OVS_FRAG_TYPE_LATER,
>>> +       __OVS_FRAG_TYPE_MAX
>>> +};
>>> +
>>> +#define OVS_FRAG_TYPE_MAX (__OVS_FRAG_TYPE_MAX - 1)
>>> +
>>> +struct ovs_key_ethernet {
>>> +       __u8     eth_src[6];
>>> +       __u8     eth_dst[6];
>>> +};
>>> +
>>> +struct ovs_key_ipv4 {
>>> +       __be32 ipv4_src;
>>> +       __be32 ipv4_dst;
>>> +       __u8   ipv4_proto;
>>> +       __u8   ipv4_tos;
>>> +       __u8   ipv4_ttl;
>>> +       __u8   ipv4_frag;       /* One of OVS_FRAG_TYPE_*. */
>>> +};
>>> +
>>> +struct ovs_key_ipv6 {
>>> +       __be32 ipv6_src[4];
>>> +       __be32 ipv6_dst[4];
>>> +       __be32 ipv6_label;      /* 20-bits in least-significant bits. */
>>> +       __u8   ipv6_proto;
>>> +       __u8   ipv6_tclass;
>>> +       __u8   ipv6_hlimit;
>>> +       __u8   ipv6_frag;       /* One of OVS_FRAG_TYPE_*. */
>>> +};
>>> +
>>> +struct ovs_key_tcp {
>>> +       __be16 tcp_src;
>>> +       __be16 tcp_dst;
>>> +};
>>> +
>>> +struct ovs_key_udp {
>>> +       __be16 udp_src;
>>> +       __be16 udp_dst;
>>> +};
>>> +
>>> +struct ovs_key_icmp {
>>> +       __u8 icmp_type;
>>> +       __u8 icmp_code;
>>> +};
>>> +
>>> +struct ovs_key_icmpv6 {
>>> +       __u8 icmpv6_type;
>>> +       __u8 icmpv6_code;
>>> +};
>>> +
>>> +struct ovs_key_arp {
>>> +       __be32 arp_sip;
>>> +       __be32 arp_tip;
>>> +       __be16 arp_op;
>>> +       __u8   arp_sha[6];
>>> +       __u8   arp_tha[6];
>>> +};
>>> +
>>> +struct ovs_key_nd {
>>> +       __u32 nd_target[4];
>>> +       __u8  nd_sll[6];
>>> +       __u8  nd_tll[6];
>>> +};
>>> +
>>
>> We already have defines for many of these headers
>> struct arphdr {
>>        __be16          ar_hrd;         /* format of hardware address   */
>>        __be16          ar_pro;         /* format of protocol address   */
>>        unsigned char   ar_hln;         /* length of hardware address   */
>>        unsigned char   ar_pln;         /* length of protocol address   */
>>        __be16          ar_op;          /* ARP opcode (command)         */
>>
>> #if 0
>>         /*
>>          *      Ethernet looks like this : This bit is variable sized however...
>>          */
>>        unsigned char           ar_sha[ETH_ALEN];       /* sender hardware address      */
>>        unsigned char           ar_sip[4];              /* sender IP address            */
>>        unsigned char           ar_tha[ETH_ALEN];       /* target hardware address      */
>>        unsigned char           ar_tip[4];              /* target IP address            */
>> #endif
>>
>> };
>>
>> Do we have to redefine them here?
> 
> These aren't packet format definitions, they're keys for describing a
> flow to userspace.  For example, they don't contain checksums or
> lengths because those vary on a per-packet basis.

OK thanks for explaining. I get it now, the other responses seem reasonable
as well.

Thanks,
John.
