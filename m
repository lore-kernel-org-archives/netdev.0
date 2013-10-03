From: Jon Mason <jon.mason@intel.com>
Subject: Re: [PATCH RFC 54/77] ntb: Ensure number of MSIs on
 SNB is enough for the link interrupt
Date: Wed, 2 Oct 2013 17:48:05 -0700
Message-ID: <20131003004805.GL6768@jonmason-lab>
References: <cover.1380703262.git.agordeev@redhat.com>
	<5d9c5b2d3bbc444ff32bddeece7a239d046bd79c.1380703263.git.agordeev@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org, "VMware, Inc." <pv-drivers@vmware.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	linux-nvme@lists.infradead.org, linux-ide@vger.kernel.org,
	stable@vger.kernel.org, linux-s390@vger.kernel.org,
	Andy King <acking@vmware.com>, linux-scsi@vger.kernel.org,
	linux-rdma@vger.kernel.org, x86@kernel.org,
	Ingo Molnar <mingo@redhat.com>, linux-pci@vger.kernel.org,
	Matt Porter <mporter@kernel.crashing.org>, iss_storagedev@hp.com,
	linux-driver@qlogic.com, Michael Ellerman <michael@ellerman.id.au>,
	Tejun Heo <tj@kernel.org>, Bjorn Helgaas <bhelgaas@google.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ralf Baechle <ralf@linux-mips.org>, e1000-devel@lists.sourceforge.net,
	Martin Schwidefsky <schwidefsky@de.ibm.com>, linux390@de.ibm.c
To: Alexander Gordeev <agordeev@redhat.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <5d9c5b2d3bbc444ff32bddeece7a239d046bd79c.1380703263.git.agordeev@redhat.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Wed, Oct 02, 2013 at 12:49:10PM +0200, Alexander Gordeev wrote:
> Signed-off-by: Alexander Gordeev <agordeev@redhat.com>
> ---
>  drivers/ntb/ntb_hw.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/ntb/ntb_hw.c b/drivers/ntb/ntb_hw.c
> index de2062c..eccd5e5 100644
> --- a/drivers/ntb/ntb_hw.c
> +++ b/drivers/ntb/ntb_hw.c
> @@ -1066,7 +1066,7 @@ static int ntb_setup_msix(struct ntb_device *ndev)
>  		/* On SNB, the link interrupt is always tied to 4th vector.  If
>  		 * we can't get all 4, then we can't use MSI-X.
>  		 */
> -		if (ndev->hw_type != BWD_HW) {
> +		if ((rc < SNB_MSIX_CNT) && (ndev->hw_type != BWD_HW)) {

Nack, this check is unnecessary.

Also, no comment in the commit on why it could be necessary.


>  			rc = -EIO;
>  			goto err1;
>  		}
> -- 
> 1.7.7.6
> 

------------------------------------------------------------------------------
October Webinars: Code for Performance
Free Intel webinars can help you accelerate application performance.
Explore tips for MPI, OpenMP, advanced profiling, and more. Get the most from 
the latest Intel processors and coprocessors. See abstracts and register >
http://pubads.g.doubleclick.net/gampad/clk?id=60134791&iu=/4140/ostg.clktrk
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
