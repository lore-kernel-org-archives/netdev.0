From: "Ira W. Snyder" <iws@ovro.caltech.edu>
Subject: Using virtio as a physical (wire-level) transport
Date: Wed, 4 Aug 2010 16:04:41 -0700
Message-ID: <20100804230441.GJ23951@ovro.caltech.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Zang Roy <r61911@freescale.com>,
        virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>,
        Rusty Russell <rusty@rustcorp.com.au>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
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

Hello Michael, Rusty,

I'm trying to figure out how to use virtio-net and vhost-net to
communicate over a physical transport (PCI bus) instead of shared
memory (for example, qemu/kvm guest).

We've talked about this several times in the past, and I currently have
some time to devote to this again. I'm trying to figure out if virtio is
still a viable solution, or if it has been evolved such that it is
unusable for this application.

I am trying to create a generic system to allow the  type of
communications described below. I would like to create something that
can be easily ported to any slave computer which meets the following
requirements:

1) it is a PCI slave (agent) (it acts like any other PCI card)
2) it has an inter-processor communications mechanism
3) it has a DMA engine

There is a reasonable amount of demand for such a system. I get
inquiries about the prototype code I posted to linux-netdev at least
once a month. This sort of system is used regularly in the
telecommunications industry, among others.

Here is a quick drawing of the system I work with. Please forgive my
poor ascii art skills.

+-----------------+
| master computer |
|                 |                             +-------------------+
| PCI slot #1     | <-- physical connection --> | slave computer #1 |
| virtio-net if#1 |                             | vhost-net if#1    |
|                 |                             +-------------------+
|                 |
|                 |                             +-------------------+
| PCI slot #2     | <-- physical connection --> | slave computer #2 |
| virtio-net if#2 |                             | vhost-net if#2    |
|                 |                             +-------------------+
|                 |
|                 |                             +-------------------+
| PCI slot #n     | <-- physical connection --> | slave computer #n |
| virtio-net if#n |                             | vhost-net if#n    |
|                 |                             +-------------------+
+-----------------+

The reason for using vhost-net on the "slave" side is because vhost-net
is the component that performs data copies. In most cases, the slave
computers are non-x86 and have DMA controllers. DMA is an absolute
necessity when copying data across the PCI bus.

Do you think virtio is a viable solution to solve this problem? If not,
can you suggest anything else?

Another reason I ask this question is that I have previously invested
several months implementing a similar solution, only to have it outright
rejected for "not being the right way". If you don't think something
like this has any hope, I'd rather not waste another month of my life.
If you can think of a solution that is likely to be "the right way", I'd
rather you told me before I implement any code.

Making my life harder since the last time I tried this, mainline commit
7c5e9ed0c (virtio_ring: remove a level of indirection) has removed the
possibility of using an alternative virtqueue implementation. The commit
message suggests that you might be willing to add this capability back.
Would this be an option?

Thanks for your time,
Ira
