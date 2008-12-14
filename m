From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH] AF_VMCHANNEL address family for guest<->host communication.
Date: Sun, 14 Dec 2008 15:23:20 +0300
Message-ID: <20081214122320.GA32472@ioremap.net>
References: <20081214115054.4066.14557.stgit@dhcp-1-237.tlv.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	kvm@vger.kernel.org
To: Gleb Natapov <gleb@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081214115054.4066.14557.stgit@dhcp-1-237.tlv.redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Gleb.

On Sun, Dec 14, 2008 at 01:50:55PM +0200, Gleb Natapov (gleb@redhat.com) wrote:
> There is a need for communication channel between host and various
> agents that are running inside a VM guest. The channel will be used
> for statistic gathering, logging, cut & paste, host screen resolution
> changes notifications, guest configuration etc.
> 
> It is undesirable to use TCP/IP for this purpose since network
> connectivity may not exist between host and guest and if it exists the
> traffic can be not routable between host and guest for security reasons
> or TCP/IP traffic can be firewalled (by mistake) by unsuspecting VM user.
> 
> This patch implement new address family AF_VMCHANNEL that is used
> for communication between guest and host. Channels are created at VM
> start time. Each channel has a name. Agent, that runs on a guest, can
> send/receive data to/from a channel by creating AF_VMCHANNEL socket and
> connecting to a channel using channels name as an address.
> 
> Only stream sockets are supported by this implementation. Also only
> connect, sendmsg and recvmsg socket ops are implemented which is enough
> to allow application running in a guest to connect to a channel created
> by a host and read/write from/to the channel. This can be extended to
> allow channel creation from inside a guest by creating listen socket and
> accepting on it if the need will arise and thus even allow guest<->guest
> communication in the future (but TCP/IP may be preferable for this).

Couple of comments on this.
First, there is only single virtio device initialized at probe time,
how this will work on the host system with multiple guests? Is it
possible to have multiple virtual devices?
Second, each virtual device has an array of names, and each socket can
be bound to one of them, but it is not allowed to have multiple sockets
bound to the same name, so it looks like there is no possibility to have
several sockets communicating via signel channel, was this intentional?
And third, tasklet callbacks do not use bh socket locking, and while it
is not something bad, but rt folks want (dream) to replace it with
process context, so this at least requires some note in comments.

Except that about questions, this patch looks good.

-- 
	Evgeniy Polyakov
