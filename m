From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [net-next][PATCH v2 11/13] RDS: IB: add Fastreg MR (FRMR)
 detection support
Date: Sun, 28 Feb 2016 01:08:58 -0800
Message-ID: <20160228090858.GB6671@infradead.org>
References: <1456625990-4739-1-git-send-email-santosh.shilimkar@oracle.com>
 <1456625990-4739-12-git-send-email-santosh.shilimkar@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org
To: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1456625990-4739-12-git-send-email-santosh.shilimkar@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Feb 27, 2016 at 06:19:48PM -0800, Santosh Shilimkar wrote:
> Discovere Fast Memmory Registration support using IB device
> IB_DEVICE_MEM_MGT_EXTENSIONS. Certain HCA might support just FRMR
> or FMR or both FMR and FRWR. In case both mr type are supported,
> default FMR is used.
> 
> Default MR is still kept as FMR against what everyone else
> is following. Default will be changed to FRMR once the
> RDS performance with FRMR is comparable with FMR. The
> work is in progress for the same.
> 
> Signed-off-by: Santosh Shilimkar <ssantosh@kernel.org>
> Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
> ---
> v2: Dropped the module parameter as suggested by David Miller

This means we only use the safer method if the HCA doesn't support
the other one.  All other RDMA ULP that support both methods have
a module_param so the veto from Dave is a bit unfortunate.  Anyway,
let's get the code in for now and figure out what to use later.

Just curious:  where / how do you see worse peformance using FRs?
