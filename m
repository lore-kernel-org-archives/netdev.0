From: Joe Stringer <joestringer@nicira.com>
Subject: Re: [PATCH net-next 5/9] openvswitch: Add conntrack action
Date: Fri, 31 Jul 2015 13:14:11 -0700
Message-ID: <CANr6G5wk2MpQMksG7bVBx2jZ_vcW1N4=3C+UjbJm5aPOj6Zr7w@mail.gmail.com>
References: <1438279963-29563-1-git-send-email-joestringer@nicira.com>
 <1438279963-29563-6-git-send-email-joestringer@nicira.com> <1438356362.20479.16.camel@redhat.com>
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
In-Reply-To: <1438356362.20479.16.camel@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 31 July 2015 at 08:26, Hannes Frederic Sowa <hannes@redhat.com> wrote:
> On Thu, 2015-07-30 at 11:12 -0700, Joe Stringer wrote:
>> +static void do_output(struct datapath *dp, struct sk_buff *skb, int
>> out_port,
>> +                   struct sw_flow_key *key)
>>  {
>>       struct vport *vport = ovs_vport_rcu(dp, out_port);
>>
>> -     if (likely(vport))
>> -             ovs_vport_send(vport, skb);
>> -     else
>> +     if (likely(vport)) {
>> +             unsigned int mru = OVS_CB(skb)->mru;
>> +             struct dst_entry *orig_dst = dst_clone(skb_dst(skb));
>
> I think you forgot to remove this?

You're right that it's incorrect, however we do still need to ensure
that the original skb's reference to the orig_dst is released. I'll
tidy this up for v2.
