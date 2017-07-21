From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Re: [PATCH 5/5] e1000e: Avoid receiver overrun interrupt bursts
Date: Fri, 21 Jul 2017 14:48:48 -0400
Message-ID: <20170721184848.GU18556@csclub.uwaterloo.ca>
References: <20170721160937.GA22632@csclub.uwaterloo.ca>
 <20170721183627.13373-1-bpoirier@suse.com>
 <20170721183627.13373-5-bpoirier@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Benjamin Poirier <bpoirier@suse.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170721183627.13373-5-bpoirier@suse.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 21, 2017 at 11:36:27AM -0700, Benjamin Poirier wrote:
> When e1000e_poll() is not fast enough to keep up with incoming traffic, the
> adapter (when operating in msix mode) raises the Other interrupt to signal
> Receiver Overrun.
> 
> This is a double problem because 1) at the moment e1000_msix_other()
> assumes that it is only called in case of Link Status Change and 2) if the
> condition persists, the interrupt is repeatedly raised again in quick
> succession.
> 
> Ideally we would configure the Other interrupt to not be raised in case of
> receiver overrun but this doesn't seem possible on this adapter. Instead,
> we handle the first part of the problem by reverting to the practice of
> reading ICR in the other interrupt handler, like before commit 16ecba59bc33
> ("e1000e: Do not read ICR in Other interrupt"). Thanks to commit
> 0a8047ac68e5 ("e1000e: Fix msi-x interrupt automask") which cleared IAME
> from CTRL_EXT, reading ICR doesn't interfere with RxQ0, TxQ0 interrupts
> anymore. We handle the second part of the problem by not re-enabling the
> Other interrupt right away when there is overrun. Instead, we wait until
> traffic subsides, napi polling mode is exited and interrupts are
> re-enabled.
> 
> Reported-by: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>
> Fixes: 16ecba59bc33 ("e1000e: Do not read ICR in Other interrupt")
> Signed-off-by: Benjamin Poirier <bpoirier@suse.com>

Any chance of this fix hitting -stable?  After all adapter reset under
load is not nice.

-- 
Len Sorensen
