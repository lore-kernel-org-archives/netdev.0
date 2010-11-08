From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [ovs-dev] Flow Control and Port Mirroring
Date: Mon, 8 Nov 2010 13:41:23 +1030
Message-ID: <201011081341.23529.rusty@rustcorp.com.au>
References: <20101028115403.GA16206@verge.net.au>
	<AANLkTi=QXBi4wmJS1TY0P=s+11Vjp0v=AfWOdFb4vrCj@mail.gmail.com>
	<20101030025932.GG12842@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev@openvswitch.org, kvm@vger.kernel.org,
        "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
        Jesse Gross <jesse@nicira.com>, virtualization@lists.osdl.org
To: virtualization@lists.linux-foundation.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20101030025932.GG12842@verge.net.au>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/virtualization>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Sat, 30 Oct 2010 01:29:33 pm Simon Horman wrote:
> [ CCed VHOST contacts ]
> 
> On Thu, Oct 28, 2010 at 01:22:02PM -0700, Jesse Gross wrote:
> > On Thu, Oct 28, 2010 at 4:54 AM, Simon Horman <horms@verge.net.au> wrote:
> > > My reasoning is that in the non-mirroring case the guest is
> > > limited by the external interface through wich the packets
> > > eventually flow - that is 1Gbit/s. But in the mirrored either
> > > there is no flow control or the flow control is acting on the
> > > rate of dummy0, which is essentailly infinate.
> > >
> > > Before investigating this any further I wanted to ask if
> > > this behaviour is intentional.
> > 
> > It's not intentional but I can take a guess at what is happening.
> > 
> > When we send the packet to a mirror, the skb is cloned but only the
> > original skb is charged to the sender.  If the original packet is
> > delivered to localhost then it will be freed quickly and no longer
> > accounted for, despite the fact that the "real" packet is still
> > sitting in the transmit queue on the NIC.  The UDP stack will then
> > send the next packet, limited only by the speed of the CPU.
> 
> That would explain what I have observed.

I can't find the thread (what is ovs-dev?), but I think the tap device
has this fundamental feature: you can blast as many packets as you want
through it.

If that's a bad thing, we have to look harder...

Cheers,
Rusty.
