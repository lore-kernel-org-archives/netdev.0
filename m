From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH] AF_VMCHANNEL address family for guest<->host communication.
Date: Tue, 16 Dec 2008 02:45:11 +0300
Message-ID: <20081215234511.GA24579@ioremap.net>
References: <4946717F.2090809@codemonkey.ws> <20081215.114315.165733593.davem@davemloft.net> <4946C1AA.4080404@codemonkey.ws> <20081215.142918.190909950.davem@davemloft.net> <4946E1BA.80206@codemonkey.ws>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, gleb@redhat.com,
	netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	kvm@vger.kernel.org
To: Anthony Liguori <anthony@codemonkey.ws>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4946E1BA.80206@codemonkey.ws>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Anthony.

On Mon, Dec 15, 2008 at 05:01:14PM -0600, Anthony Liguori (anthony@codemonkey.ws) wrote:
> Yes, and I went down the road of using a dedicated network device and 
> using raw ethernet as the protocol.  The thing that killed that was the 
> fact that it's not reliable.  You need something like TCP to add 
> reliability.
> 
> But that's a lot of work and a bit backwards.  Use a unreliable 
> transport but use TCP on top of it to get reliability.  Our link 
> (virtio) is inherently reliable so why not just expose a reliable 
> interface to userspace?

I removed original mail and did not check archive, but doesn't rx/tx
queues of the virtio device have limited size? I do hope they have,
which means that either your network drops packets or blocks.


Having dedicated preconfigured network device is essentially the same as
having this special socket option: guests which do not have this (either
network or vchannel socket) will not be able to communicate with the
host, so there is no difference. Except that usual network will just
work out of the box (and especially you will like it when there will be
no need to hack on X to support new network media).

Another approach is to implement that virtio backend with netlink based
userspace interface (like using connector or genetlink). This does not
differ too much from what you have with special socket family, but at
least it does not duplicate existing functionality of
userspace-kernelspace communications.

But IMO having special network device or running your protocol over
existing virtio network device is a cleaner solution both from technical
and convenience points of view.

-- 
	Evgeniy Polyakov
