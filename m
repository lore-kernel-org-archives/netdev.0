From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] vhost-net: add module alias
Date: Wed, 11 Jan 2012 08:58:57 -0800
Message-ID: <20120111085857.0753322f@nehalam.linuxnetplumber.net>
References: <20120110205400.6c1cb306@nehalam.linuxnetplumber.net>
	<4F0D3543.7020401@msgid.tls.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	Kay Sievers <kay.sievers@vrfy.org>, kvm@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Michael Tokarev <mjt@tls.msk.ru>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <4F0D3543.7020401@msgid.tls.msk.ru>
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

On Wed, 11 Jan 2012 11:07:47 +0400
Michael Tokarev <mjt@tls.msk.ru> wrote:

> On 11.01.2012 08:54, Stephen Hemminger wrote:
> > By adding the a module alias, programs (or users) won't have to explicitly
> > call modprobe. Vhost-net will always be available if built into the kernel.
> > It does require assigning a permanent minor number for depmod to work.
> > Choose one next to TUN since this driver is related to it.
> 
> Why do you think a statically-allocated device number will do any good
> at all?  Static /dev is gone almost completely, at least on the systems
> where whole virt stuff makes any sense, so you don't have pre-created
> vhost-net device anymore, and hence this allocation makes no sense.
> Just IMHO anyway.

The statically allocated device number is required for the udev/module
autoloading to work. Probably the udev infrastructure needs a consistent
number to hang off of.

It looks like:
  * driver adds MODULE_ALIAS() for devname and character device
  * depmod scans modules and creates modules.devname (in /lib/modules)
  * udev uses modules.devname to autoload the module

$ /sbin/modinfo vhost_net
filename:       /lib/modules/3.2.0-net+/kernel/drivers/vhost/vhost_net.ko
alias:          devname:vhost-net
alias:          char-major-10-201
description:    Host kernel accelerator for virtio net
...

See also: https://lkml.org/lkml/2010/5/21/134
