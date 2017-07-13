From: Joe Stringer <joe-LZ6Gd1LRuIk@public.gmane.org>
Subject: Re: [PATCH net-next v1 0/3] Flow Based GTP Tunneling
Date: Wed, 12 Jul 2017 18:28:29 -0700
Message-ID: <CAPWQB7Fv5VHwVt-65w9v=VvqXcprT6cRBQyKv5U8gZ+gL1WH7w@mail.gmail.com>
References: <20170713004455.3946570-1-ouyangj@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: ovs dev <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	osmocom-net-gprs-qjLDD68F18N4m7O/Vxda39i2O/JbrIOy@public.gmane.org, laforge-TgoAw6mPHtdg9hUCZPvPmw@public.gmane.org,
	Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>
To: Jiannan Ouyang <ouyangj-b10kYP2dOMg@public.gmane.org>
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20170713004455.3946570-1-ouyangj-b10kYP2dOMg@public.gmane.org>
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

On 12 July 2017 at 17:44, Jiannan Ouyang <ouyangj-b10kYP2dOMg@public.gmane.org> wrote:
> This patch series augmented the existing GTP module to support flow
> based GTP tunneling and modified the openvswitch datapath to support the
> GTP vport type.
>
> A flow based GTP net device enables that,
> 1) on the RX path, the outer (IP/UDP/GTP) header information could to be
> stored in the metadata_dst struct, and embedded into the skb.
> 2) on the TX path, packets are encapsulated following instructions in
> the metadata_dst field of the skb.
>
> A flow based GTP net device can be integrated with Open vSwitch, which
> allows SDN controllers to program GTP tunnels via Open vSwitch.
>
> Open vSwitch changes are based on patch set
>     [PATCH] Add GTP vport based on upstream datapath
>
> Example usage with OVS:
>
> ovs-vsctl add-port br0 gtp-vport -- set interface gtp-vport \
>     ofport_request=2 type=gtp option:remote_ip=flow options:key=flow
>
> ovs-ofctl add-flow br0
>     "in_port=2,tun_src=192.168.60.141,tun_id=123, \
>     actions=set_field:02:00:00:00:00:00->eth_src, \
>     set_field:ff:ff:ff:ff:ff:ff->eth_dst,LOCAL"
>
> ovs-ofctl add-flow br0 \
>     "in_port=LOCAL,actions=set_tunnel:888, \
>     set_field:192.168.60.141->tun_dst,2"
>
> arp -s 10.1.1.122 02:00:00:00:00:00
>
> Jiannan Ouyang (3):
>   gtp: refactor to support flow-based gtp encap and decap
>   gtp: Support creating flow-based gtp net_device
>   openvswitch: Add GPRS Tunnel Protocol (GTP) vport support

Hi Jiannan,

net-next is closed, Dave won't accept patches at this time.

Some brief feedback in regards to patch #3, the preference these days
is for OVS userspace to use rtnetlink to configure devices in
COLLECT_METADATA mode, then attach those devices as regular
vport-netdev device type to OVS kernel datapath. I think that should
mean that no kernel changes to openvswitch are required for providing
GTP vports. Instead of this patch it would require something similar
to the IFLA_GRE_COLLECT_METADATA flag which GRE has, but for the GTP
devices. The latest OVS master now supports configuring devices in
this way, perhaps you could take a look at OVS tree's
lib/dpif-netlink-rtnl.c to see how other tunnel devices are configured
and see if that makes sense for GTP as well?

Cheers,
Joe
