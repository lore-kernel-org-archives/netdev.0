From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: [net-next PATCH 1/2] PCI: Add PCI quirk to disable L0s ASPM state for 82575 and 82598
Date: Tue, 3 Mar 2009 21:05:26 -0700
Message-ID: <20090304040526.GB1884@parisc-linux.org>
References: <20090304020308.15176.40527.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	linux-pci <linux-pci@vger.kernel.org>,
	Matthew Wilcox <willy@linux.intel.com>,
	Jesse Barnes <jbarnes@virtuousgeek.org>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090304020308.15176.40527.stgit@lost.foo-projects.org>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 03, 2009 at 06:03:09PM -0800, Jeff Kirsher wrote:
> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> This patch is intended to disable L0s ASPM link state for 82598 (ixgbe)
> parts due to the fact that it is possible to corrupt TX data when coming
> back out of L0s on some systems.  The workaround had been added for 82575
> (igb) previously, but did not use the ASPM api.  This quirk uses the ASPM
> api to prevent the ASPM subsystem from re-enabling the L0s state.
> 
> Instead of adding the fix in igb to the ixgbe driver as well it was
> decided to move it into a pci quirk.  It is necessary to move the fix out
> of the driver and into a pci quirk in order to prevent the issue from
> occuring prior to driver load to handle the possibility of the device being
> passed to a VM via direct assignment.

Thanks for the explanation, it handles my immediate question of "why do
it in a quirk?"  It does, however, raise the very interesting question
about what to do about other devices which have issues that are currently
handled in the driver that can't be handled by the driver in a VM.  
I don't have a good example to hand right now, but I bet I can spot one
when I'm less tired.

> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> CC: linux-pci <linux-pci@vger.kernel.org>
> CC: Matthew Wilcox <willy@linux.intel.com>
> CC: Jesse Barnes <jbarnes@virtuousgeek.org>

I'm not going to ack this patch at this point, let's just give it a day.
FWIW, Jesse is not going to be able to review patches this week.

-- 
Matthew Wilcox				Intel Open Source Technology Centre
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."
