From: Andy King <acking@vmware.com>
Subject: Re: [Pv-drivers] [PATCH 0/6] VSOCK for Linux upstreaming
Date: Thu, 6 Dec 2012 07:28:13 -0800 (PST)
Message-ID: <882468393.42962386.1354807693049.JavaMail.root@vmware.com>
References: <50A55F57.7080804@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, pv-drivers@vmware.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	gregkh@linuxfoundation.org, David Miller <davem@davemloft.net>,
	georgezhang@vmware.com
To: Anthony Liguori <aliguori@us.ibm.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <50A55F57.7080804@us.ibm.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Hi Anthony,

> This was already done in a hypervisor neutral way using virtio:
> 
> http://lists.openwall.net/netdev/2008/12/14/8
> 
> The concept was Nacked and that led to the abomination of
> virtio-serial.  If an address family for virtualization is on the
> table, we should reconsider AF_VMCHANNEL.

I finally had a look at your patch.  Please correct me if I'm wrong,
but it seems that the peer of an AF_VMCHANNEL connection is a virtio
channel inside the hypervisor, i.e., the other end is _not_ sockets,
right?

That's quite a bit different from vSockets, where both sides use the
socket interface, even within the VMX process in our hypervisor.  We
also intend for arbitrary host processes -- those outside the
hypervisor -- to use it via the sockets interface.  We have shipping
applications that do just that, where communication is between a guest
process and a host service, with both sides using the standard socket
API but with the vSockets address family.  We also encourage people to
write such VM-to-host applications, and we've been shipping the
vSockets header in our host-side products to allow people to do just
that.

So I think in that sense vSockets is somewhat more general, and we'd
obviously prefer to go with our socket family and address structure
if LKML is open to something like this.

Thanks!
- Andy

PS I realize we still owe LKML a spec for the vSockets protocol.
