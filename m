From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [[PATCH stable <3.12]] xen-netback: fix refcnt unbalance for
 3.11 and earlier versions
Date: Sat, 30 Nov 2013 20:48:35 -0800
Message-ID: <20131201044835.GB19516@kroah.com>
References: <1385642889-11513-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: xen-devel@lists.xen.org, netdev@vger.kernel.org,
	stable@vger.kernel.org, tomasz.wroblewski@citrix.com,
	Ian Campbell <ian.campbell@citrix.com>,
	Konrad Wilk <konrad.wilk@oracle.com>,
	David Vrabel <david.vrabel@citrix.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1385642889-11513-1-git-send-email-wei.liu2@citrix.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 28, 2013 at 12:48:09PM +0000, Wei Liu wrote:
> With the introduction of "xen-netback: Don't destroy the netdev until
> the vif is shut down" (upstream commit id 279f438e36), vif disconnect
> and free are separated. However in the backported verion reference
> counting code was not correctly modified, and the reset of vif->tx_irq
> was lost. If frontend goes through vif life cycle more than once the
> reference counting is skewed.
> 
> This patch adds back the missing tx_irq reset line. It also moves
> several lines of the reference counting code to vif_free, so the moved
> code corresponds to the counterpart in vif_alloc, thus the reference
> counting is balanced.
> 
> 3.12 and onward versions are not affected by this bug, because reference
> counting code was removed due to the introduction of 1:1 model.
> 
> This pacth should be backported to all stable verions which are lower
> than 3.12 and have 279f438e36.

What stable versions are those?  279f438e36 showed up in 3.12-rc2, and
was not marked for stable inclusion, so what kernel would end up needing
this patch?

confused,

greg k-h
