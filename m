From: Joe Stringer <joestringer@nicira.com>
Subject: Re: [PATCH net-next 1/9] openvswitch: Scrub packet in ovs_vport_receive()
Date: Fri, 31 Jul 2015 10:51:11 -0700
Message-ID: <CANr6G5zsh2DUDBrZpQBpFO_GggvPa4ztdwDxRQuByzwU-S-FUg@mail.gmail.com>
References: <1438279963-29563-1-git-send-email-joestringer@nicira.com>
 <1438279963-29563-2-git-send-email-joestringer@nicira.com> <1438353294.20479.7.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Justin Pettit <jpettit@nicira.com>,
	Pravin Shelar <pshelar@nicira.com>,
	Andy Zhou <azhou@nicira.com>, Jesse Gross <jesse@nicira.com>,
	Florian Westphal <fwestpha@redhat.com>,
	Thomas Graf <tgraf@noironetworks.com>
To: Hannes Frederic Sowa <hannes@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438353294.20479.7.camel@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 31 July 2015 at 07:34, Hannes Frederic Sowa <hannes@redhat.com> wrote:
> On Thu, 2015-07-30 at 11:12 -0700, Joe Stringer wrote:
>> Signed-off-by: Joe Stringer <joestringer@nicira.com>
>> ---
>>  net/openvswitch/vport.c | 3 +++
>>  1 file changed, 3 insertions(+)
>>
>> diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
>> index d14f594..baa018f 100644
>> --- a/net/openvswitch/vport.c
>> +++ b/net/openvswitch/vport.c
>> @@ -475,6 +475,9 @@ void ovs_vport_receive(struct vport *vport, struct
>> sk_buff *skb,
>>       struct sw_flow_key key;
>>       int error;
>>
>> +     if (!skb->sk || (sock_net(skb->sk) != read_pnet(&vport->dp
>> ->net)))
>> +             skb_scrub_packet(skb, true);
>> +
>>       stats = this_cpu_ptr(vport->percpu_stats);
>>       u64_stats_update_begin(&stats->syncp);
>>       stats->rx_packets++;
>
> In general, this shouldn't be necessary as the packet should already be
> scrubbed before they arrive here.
>
> Could you maybe add a WARN_ON and check how those skbs with conntrack
> data traverse the stack? I also didn't understand why make it dependent
> on the socket.

OK, sure. One case I could think of is with an OVS internal port in
another namespace, directly attached to the bridge. I'll have a play
around with WARN_ON and see if I can come up with something more
trimmed down.
