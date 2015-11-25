From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC PATCH V2 3/3] Ixgbevf: Add migration support for ixgbevf
 driver
Date: Wed, 25 Nov 2015 18:22:10 +0200
Message-ID: <20151125181618-mutt-send-email-mst@redhat.com>
References: <1448372298-28386-1-git-send-email-tianyu.lan@intel.com>
 <1448372298-28386-4-git-send-email-tianyu.lan@intel.com>
 <20151124230551-mutt-send-email-mst@redhat.com>
 <56554994.1090305@intel.com>
 <20151125142437-mutt-send-email-mst@redhat.com>
 <5655DB99.3040007@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: a.motakis@virtualopensystems.com, alex.williamson@redhat.com,
	b.reynal@virtualopensystems.com, bhelgaas@google.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	eddie.dong@intel.com, nrupal.jani@intel.com, agraf@suse.de,
	kvm@vger.kernel.org, pbonzini@redhat.com, qemu-devel@nongnu.org,
	emil.s.tantilov@intel.com, gerlitz.or@gmail.com,
	mark.d.rustad@intel.com, eric.auger@linaro.org,
	intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, john.ronciak@intel.com,
	linux-api@vger.kernel.org, linux-kernel@vger.kernel.org,
	matthew.vick@intel.com, mitch.a.williams@intel.com,
	netdev@vger.kernel.org, shannon.nelson@intel.com,
	weiyang@linux.vnet.ibm.com, zajec5@gmail.com
To: "Lan, Tianyu" <tianyu.lan@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5655DB99.3040007@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 26, 2015 at 12:02:33AM +0800, Lan, Tianyu wrote:
> On 11/25/2015 8:28 PM, Michael S. Tsirkin wrote:
> >Frankly, I don't really see what this short term hack buys us,
> >and if it goes in, we'll have to maintain it forever.
> >
> 
> The framework of how to notify VF about migration status won't be
> changed regardless of stopping VF or not before doing migration.
> We hope to reach agreement on this first.

Well it's bi-directional, the framework won't work if it's
uni-directional.
Further, if you use this interface to stop the interface
at the moment, you won't be able to do anything else
with it, and will need a new one down the road.


> Tracking dirty memory still
> need to more discussions and we will continue working on it. Stop VF may
> help to work around the issue and make tracking easier.
> 
> 
> >Also, assuming you just want to do ifdown/ifup for some reason, it's
> >easy enough to do using a guest agent, in a completely generic way.
> >
> 
> Just ifdown/ifup is not enough for migration. It needs to restore some PCI
> settings before doing ifup on the target machine

I'd focus on just restoring then.

-- 
MST
