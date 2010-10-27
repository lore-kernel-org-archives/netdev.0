From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RFC PATCH] macvlan: Introduce a PASSTHRU mode to takeover the underlying device
Date: Wed, 27 Oct 2010 16:05:29 +0200
Message-ID: <201010271605.29201.arnd@arndb.de>
References: <1288131578.7582.49.camel@sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1288131578.7582.49.camel@sridhar.beaverton.ibm.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 27 October 2010, Sridhar Samudrala wrote:
> With the current default macvtap mode, a KVM guest using virtio with 
> macvtap backend has the following limitations.
> - cannot change/add a mac address on the guest virtio-net
> - cannot create a vlan device on the guest virtio-net
> - cannot enable promiscuous mode on guest virtio-net
> 
> This patch introduces a new mode called 'passthru' when creating a 
> macvlan device which allows takeover of the underlying device and 
> passing it to a guest using virtio with macvtap backend.
> 
> Only one macvlan device is allowed in passthru mode and it inherits
> the mac address from the underlying device and sets it in promiscuous 
> mode to receive and forward all the packets.

Interesting approach. It somewhat stretches the definition of the
macvlan concept, but it does sound useful to have.

I was thinking about adding a new tap frontend driver that could
share some code with macvtap and do only the takeover but not
use macvlan as a base. I believe that would be a cleaner abstraction,
but your code has two advantages in that the implementation is much
simpler and that it can share a fair amount of the infrastructure
that we're putting into qemu/libvirt/etc.

	Arnd

PS: Please add a Signed-off-by: line when sending a patch, even for
discussion.
