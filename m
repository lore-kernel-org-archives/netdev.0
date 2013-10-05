From: Alexander Gordeev <agordeev@redhat.com>
Subject: Re: [PATCH RFC 54/77] ntb: Ensure number of MSIs on SNB is enough
 for the link interrupt
Date: Sat, 5 Oct 2013 23:43:04 +0200
Message-ID: <20131005214303.GA21589@dhcp-26-207.brq.redhat.com>
References: <cover.1380703262.git.agordeev@redhat.com>
 <5d9c5b2d3bbc444ff32bddeece7a239d046bd79c.1380703263.git.agordeev@redhat.com>
 <20131003004805.GL6768@jonmason-lab>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Bjorn Helgaas <bhelgaas@google.com>,
        Ralf Baechle <ralf@linux-mips.org>,
        Michael Ellerman <michael@ellerman.id.au>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Ingo Molnar <mingo@redhat.com>, Tejun Heo <tj@kernel.org>,
        Dan Williams <dan.j.williams@intel.com>,
        Andy King <acking@vmware.com>,
        Matt Porter <mporter@kernel.crashing.org>,
        stable@vger.kernel.org, linux-pci@vger.kernel.org,
        linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org,
        linux390@de.ibm.com, linux-s390@vger.kernel.org, x86@kernel.org,
        linux-ide@vger.kernel.org, iss_storagedev@hp.com,
        linux-nvme@lists.infradead.org, linux-rdma@vger.kernel.org,
        netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
        linux-driver@qlog
To: Jon Mason <jon.mason@intel.com>
Return-path: <linux-mips-bounce@linux-mips.org>
Content-Disposition: inline
In-Reply-To: <20131003004805.GL6768@jonmason-lab>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org

On Wed, Oct 02, 2013 at 05:48:05PM -0700, Jon Mason wrote:
> On Wed, Oct 02, 2013 at 12:49:10PM +0200, Alexander Gordeev wrote:
> > Signed-off-by: Alexander Gordeev <agordeev@redhat.com>
> > ---
> >  drivers/ntb/ntb_hw.c |    2 +-
> >  1 files changed, 1 insertions(+), 1 deletions(-)
> > 
> > diff --git a/drivers/ntb/ntb_hw.c b/drivers/ntb/ntb_hw.c
> > index de2062c..eccd5e5 100644
> > --- a/drivers/ntb/ntb_hw.c
> > +++ b/drivers/ntb/ntb_hw.c
> > @@ -1066,7 +1066,7 @@ static int ntb_setup_msix(struct ntb_device *ndev)
> >  		/* On SNB, the link interrupt is always tied to 4th vector.  If
> >  		 * we can't get all 4, then we can't use MSI-X.
> >  		 */
> > -		if (ndev->hw_type != BWD_HW) {
> > +		if ((rc < SNB_MSIX_CNT) && (ndev->hw_type != BWD_HW)) {
> 
> Nack, this check is unnecessary.

If SNB can do more than SNB_MSIX_CNT MSI-Xs then this check is needed
to enable less than maximum MSI-Xs in case the maximum was not allocated.
Otherwise SNB will fallback to single MSI instead of multiple MSI-Xs.

-- 
Regards,
Alexander Gordeev
agordeev@redhat.com
