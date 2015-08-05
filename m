From: Joe Stringer <joestringer@nicira.com>
Subject: Re: [PATCH net-next 1/9] openvswitch: Scrub packet in ovs_vport_receive()
Date: Tue, 4 Aug 2015 21:40:56 -0700
Message-ID: <CANr6G5xF8XFr_6PDimR5YrYr=o=CDAJnfT3Op1R1WJ3wRcuDhw@mail.gmail.com>
References: <1438279963-29563-1-git-send-email-joestringer@nicira.com>
 <1438279963-29563-2-git-send-email-joestringer@nicira.com>
 <1438353294.20479.7.camel@redhat.com> <CANr6G5zsh2DUDBrZpQBpFO_GggvPa4ztdwDxRQuByzwU-S-FUg@mail.gmail.com>
 <20150801191741.GA13837@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Hannes Frederic Sowa <hannes@redhat.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Justin Pettit <jpettit@nicira.com>,
	Pravin Shelar <pshelar@nicira.com>,
	Andy Zhou <azhou@nicira.com>, Jesse Gross <jesse@nicira.com>,
	Florian Westphal <fwestpha@redhat.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150801191741.GA13837@pox.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1 August 2015 at 12:17, Thomas Graf <tgraf@suug.ch> wrote:
> On 07/31/15 at 10:51am, Joe Stringer wrote:
>> On 31 July 2015 at 07:34, Hannes Frederic Sowa <hannes@redhat.com> wrote:
>> > In general, this shouldn't be necessary as the packet should already be
>> > scrubbed before they arrive here.
>> >
>> > Could you maybe add a WARN_ON and check how those skbs with conntrack
>> > data traverse the stack? I also didn't understand why make it dependent
>> > on the socket.
>>
>> OK, sure. One case I could think of is with an OVS internal port in
>> another namespace, directly attached to the bridge. I'll have a play
>> around with WARN_ON and see if I can come up with something more
>> trimmed down.
>
> The OVS internal port will definitely pass through an unscrubbed
> packet across namespaces. I think the proper thing to do would be
> to scrub but conditionally keep metadata.

It's only "unscrubbed" when receiving from local stack at the moment.
Some pieces are cleared when handing towards the local stack, and
there's no configuration for that behaviour. Presumably internal port
transmit and receive should mirror each other?

I don't have a specific use case either way. The remaining code for
this series handles this case correctly, it's just a matter of what
behaviour we're looking for. We could implement the flag as you say, I
presume that userspace would need to specify this during vport
creation and the default should work similar to the existing behaviour
(ie, keep metadata). One thing that's not entirely clear to me is
exactly which metadata should be represented by this flag and whether
the single flag is expressive enough.
