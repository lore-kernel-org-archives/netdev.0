From: Kay Sievers <kay.sievers@vrfy.org>
Subject: Re: [PATCH] vhost-net: add module alias
Date: Wed, 11 Jan 2012 18:03:53 +0100
Message-ID: <CAPXgP10Y6F_bdqxK6Oopkfs0Ppwwse=zjc=+h30t0ABWNOunMg@mail.gmail.com>
References: <20120110205400.6c1cb306@nehalam.linuxnetplumber.net>
 <4F0D3543.7020401@msgid.tls.msk.ru> <20120111085857.0753322f@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Michael Tokarev <mjt@tls.msk.ru>,
	"Michael S. Tsirkin" <mst@redhat.com>, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20120111085857.0753322f@nehalam.linuxnetplumber.net>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 11, 2012 at 17:58, Stephen Hemminger <shemminger@vyatta.com> wrote:
> On Wed, 11 Jan 2012 11:07:47 +0400
> Michael Tokarev <mjt@tls.msk.ru> wrote:
>
>> On 11.01.2012 08:54, Stephen Hemminger wrote:
>> > By adding the a module alias, programs (or users) won't have to explicitly
>> > call modprobe. Vhost-net will always be available if built into the kernel.
>> > It does require assigning a permanent minor number for depmod to work.
>> > Choose one next to TUN since this driver is related to it.
>>
>> Why do you think a statically-allocated device number will do any good
>> at all?

It's totally fine to use them for single-instance devices. You are
right, enumerated devices must _never_ use any facility like that.
That would just be broken.

>> Static /dev is gone almost completely, at least on the systems
>> where whole virt stuff makes any sense, so you don't have pre-created
>> vhost-net device anymore, and hence this allocation makes no sense.
>> Just IMHO anyway.

It makes a lot of sense in this case. The kernel module files
advertise the dev_t, it's not stored anywhere else. UDev finds these
static numbers and does inplicit mkdev() for them.

> The statically allocated device number is required for the udev/module
> autoloading to work. Probably the udev infrastructure needs a consistent
> number to hang off of.

It does that properly.

Just check:
  $ cat /lib/modules/$(uname -r)/modules.devname
  # Device nodes to trigger on-demand module loading.
  fuse fuse c10:229
  btrfs btrfs-control c10:234
  ppp_generic ppp c108:0
  tun net/tun c10:200
  uinput uinput c10:223
  ...

Kay
