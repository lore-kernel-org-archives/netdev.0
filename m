From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] AF_VMCHANNEL address family for guest<->host
 communication.
Date: Mon, 15 Dec 2008 15:13:16 -0800
Message-ID: <20081215151316.7523c43d@extreme>
References: <4946717F.2090809@codemonkey.ws>
	<20081215.114315.165733593.davem@davemloft.net>
	<4946C1AA.4080404@codemonkey.ws>
	<20081215.142918.190909950.davem@davemloft.net>
	<4946E1BA.80206@codemonkey.ws>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, gleb@redhat.com,
	netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	kvm@vger.kernel.org
To: Anthony Liguori <anthony@codemonkey.ws>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <4946E1BA.80206@codemonkey.ws>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 15 Dec 2008 17:01:14 -0600
Anthony Liguori <anthony@codemonkey.ws> wrote:

> David Miller wrote:
> > From: Anthony Liguori <anthony@codemonkey.ws>
> > Date: Mon, 15 Dec 2008 14:44:26 -0600
> >
> >   
> >> We want this communication mechanism to be simple and reliable as we
> >> want to implement the backends drivers in the host userspace with
> >> minimum mess.
> >>     
> >
> > One implication of your statement here is that TCP is unreliable.
> > That's absolutely not true.
> >   
> 
> No, TCP falls under the not simple category because it requires the 
> backend to have access to a TCP/IP stack.
> 
> >> Within the guest, we need the interface to be always available and
> >> we need an addressing scheme that is hypervisor specific.  Yes, we
> >> can build this all on top of TCP/IP.  We could even build it on top
> >> of a serial port.  Both have their down-sides wrt reliability and
> >> complexity.
> >>     
> >
> > I don't know of any zero-copy through the hypervisor mechanisms for
> > serial ports, but I know we do that with the various virtualization
> > network devices.
> >   
> 
> Yes, and I went down the road of using a dedicated network device and 
> using raw ethernet as the protocol.  The thing that killed that was the 
> fact that it's not reliable.  You need something like TCP to add 
> reliability.
> 
> But that's a lot of work and a bit backwards.  Use a unreliable 
> transport but use TCP on top of it to get reliability.  Our link 
> (virtio) is inherently reliable so why not just expose a reliable 
> interface to userspace?
> 
> >> Do you have another recommendation?
> >>     
> >
> > I don't have to make alternative recommendations until you can
> > show that what we have can't solve the problem acceptably, and
> > TCP emphatically can.
> >   
> 
> It can solve the problem but I don't think it's the best way to solve 
> the problem mainly because the complexity it demands on the backend.

"Those who don't understand TCP are doomed to reimplement it, badly."


