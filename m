From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next 1/9] openvswitch: Scrub packet in
 ovs_vport_receive()
Date: Fri, 31 Jul 2015 09:38:09 +0200
Message-ID: <20150731073809.GA4738@pox.localdomain>
References: <1438279963-29563-1-git-send-email-joestringer@nicira.com>
 <1438279963-29563-2-git-send-email-joestringer@nicira.com>
 <20150730184010.GC11177@pox.localdomain>
 <CANr6G5wRS1zg4oLdS5L4gM7iCS11BHb7+8uUN1fh5Oa9F4_BBw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Justin Pettit <jpettit@nicira.com>,
	Pravin Shelar <pshelar@nicira.com>,
	Andy Zhou <azhou@nicira.com>, Jesse Gross <jesse@nicira.com>,
	Florian Westphal <fwestpha@redhat.com>,
	Hannes Sowa <hannes@redhat.com>
To: Joe Stringer <joestringer@nicira.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CANr6G5wRS1zg4oLdS5L4gM7iCS11BHb7+8uUN1fh5Oa9F4_BBw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/30/15 at 04:16pm, Joe Stringer wrote:
> On 30 July 2015 at 11:40, Thomas Graf <tgraf@suug.ch> wrote:
> > On 07/30/15 at 11:12am, Joe Stringer wrote:
> >> Signed-off-by: Joe Stringer <joestringer@nicira.com>
> >
> > Can you write a few lines on why this is needed? I have flows which
> > use the mark to communicate with netfilter through internal ports.
> 
> The problem I was seeing is when packets come from a different
> namespace on the localhost, they still have conntrack data associated.
> This doesn't make sense, so the intention is to perform nf_reset().
> However, it seems like we should actually be doing a bit more - at
> least the skb_dst_drop() and perhaps some of the other stuff in
> skb_scrub_packet().
> 
> Do you want to retain the mark when transitioning between namespaces?

Since we have retained it so far I think we should keep on doing
that. I'm pretty sure there are users of it out there besides me.
As you know, it's common to have tap devices in between OVS and the
guest in OpenStack and install netfilter rules there.

As for whether we should scrub it in between namespaces. Probably yes
but it's definitely tremendously useful to be able to transfer some
metadata (mark and dst metadata) between namespaces. The default
behaviour should probably be to scrub it with a flag to keep it. If
that flag is not set and nsid of port != bridge then we scrub the mark
and other metadata.
