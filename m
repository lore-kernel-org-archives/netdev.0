From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RFC] Virtual Machine Device Queues(VMDq) support on KVM
Date: Tue, 22 Sep 2009 20:34:28 +0200
Message-ID: <200909222034.28865.arnd@arndb.de>
References: <C85CEDA13AB1CF4D9D597824A86D2B9006AEB94861@PDSMSX501.ccr.corp.intel.com> <200909221350.54847.arnd@arndb.de> <20090922092957.17e68cbc@s6510>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Chris Wright <chrisw@sous-sol.org>,
	Rusty Russell <rusty@rustcorp.com.au>,
	virtualization@lists.linux-foundation.org,
	"Xin, Xiaohui" <xiaohui.xin@intel.com>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"hpa@zytor.com" <hpa@zytor.com>, "mingo@elte.hu" <mingo@elte.hu>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20090922092957.17e68cbc@s6510>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 22 September 2009, Stephen Hemminger wrote:
> > My idea for that was to open multiple file descriptors to the same
> > macvtap device and let the kernel figure out the  right thing to
> > do with that. You can do the same with raw packed sockets in case
> > of vhost_net, but I wouldn't want to add more complexity to the
> > tun/tap driver for this.
> > 
> Or get tap out of the way entirely. The packets should not have
> to go out to user space at all (see veth)

How does veth relate to that, do you mean vhost_net? With vhost_net,
you could still open multiple sockets, only the access is in the kernel.
Obviously, once it all is in the kernel, that could be done under the
covers, but I think it would be cleaner to treat vhost_net purely as
a way to bypass the syscalls for user space, with as little as possible
visible impact otherwise.

	Arnd <><
