From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RFC PATCH v8 00/16] Provide a zero-copy method on KVM virtio-net.
Date: Wed, 4 Aug 2010 10:56:07 +0200
Message-ID: <201008041056.08505.arnd@arndb.de>
References: <1280402088-5849-1-git-send-email-xiaohui.xin@intel.com> <201007311130.17000.arnd@arndb.de> <1A42CE6F5F474C41B63392A5F80372B228FCE7B1@shsmsx501.ccr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Shirley Ma <mashirle@us.ibm.com>,
	"Xin, Xiaohui" <xiaohui.xin@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"mst@redhat.com" <mst@redhat.com>, "mingo@elte.hu" <mingo@elte.hu>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>,
	"jdike@linux.intel.com" <jdike@linux.intel.com>
To: "Dong, Eddie" <eddie.dong@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1A42CE6F5F474C41B63392A5F80372B228FCE7B1@shsmsx501.ccr.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 04 August 2010, Dong, Eddie wrote:
> Arnd Bergmann wrote:
> > On Friday 30 July 2010 17:51:52 Shirley Ma wrote:
> >> I think it should be less duplicated code in the kernel if we use
> >> macvtap to support what media passthrough driver here. Since macvtap
> >> has support virtio_net head and offloading already, the only missing
> >> func is zero copy. Also QEMU supports macvtap, we just need add a
> >> zero copy flag in option.
> > 
> > Yes, I fully agree and that was one of the intended directions for
> > macvtap to start with. Thank you so much for following up on that,
> > I've long been planning to work on macvtap zero-copy myself but it's
> > now lower on my priorities, so it's good to hear that you made
> > progress on it, even if there are still performance issues.
> > 
> 
> But zero-copy is a Linux generic feature that can be used by other
> VMMs as well if the BE service drivers want to incorporate.  If we
> can make mp device VMM-agnostic (it may be not yet in current patch),
> that will help Linux more.

But the tun/tap protocol is what most hypervisors use today on Linux,
and one of the design goals of macvtap was to keep that interface
so that everyone gets the features like zero-copy if that is added
to macvtap. The mp device interface is currently not supported by
anything else than vhost with these patches, and making it more
generic would turn the interface into a copy of macvtap.

	Arnd
