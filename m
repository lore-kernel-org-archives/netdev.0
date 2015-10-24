From: "Lan, Tianyu" <tianyu.lan@intel.com>
Subject: Re: [RFC Patch 08/12] IXGBEVF: Rework code of finding the end transmit
 desc of package
Date: Sun, 25 Oct 2015 00:08:08 +0800
Message-ID: <562BACE8.8070507@intel.com>
References: <1445445464-5056-1-git-send-email-tianyu.lan@intel.com> <1445445464-5056-9-git-send-email-tianyu.lan@intel.com> <20151022155650-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: bhelgaas@google.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, eddie.dong@intel.com,
	nrupal.jani@intel.com, yang.z.zhang@intel.com, agraf@suse.de,
	kvm@vger.kernel.org, pbonzini@redhat.com, qemu-devel@nongnu.org,
	emil.s.tantilov@intel.com, intel-wired-lan@lists.osuosl.org,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	john.ronciak@intel.com, linux-kernel@vger.kernel.org,
	linux-pci@vger.kernel.org, matthew.vick@intel.com,
	mitch.a.williams@intel.com, netdev@vger.kernel.org,
	shannon.nelson@intel.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151022155650-mutt-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 10/22/2015 8:58 PM, Michael S. Tsirkin wrote:
> Do you really need to play the shifting games?
> Can't you just reset everything and re-initialize the rings?
> It's slower but way less intrusive.
> Also removes the need to track writes into rings.

Shift ring is to avoid losing those packets in the ring.
This may cause some race condition and so I introduced a
lock to prevent such cases in the latter patch.
Yes, reset everything after migration can make thing easy.
But just like you said it would affect performance and loss
more packets. I can do a test later to get data about these
two way.
