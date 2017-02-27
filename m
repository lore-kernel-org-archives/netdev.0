From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v3 20/20] checkpatch: warn for use of old PCI pool API
Date: Mon, 27 Feb 2017 04:38:40 -0800
Message-ID: <1488199120.25838.3.camel@perches.com>
References: <20170226192425.13098-1-romain.perier@collabora.com>
         <20170226192425.13098-21-romain.perier@collabora.com>
         <20170227112233.GK26544@collabora.com>
         <7ebf56b6-4e22-05ba-2534-61cd03a2c87c@collabora.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 8bit
Cc: Dan Williams <dan.j.williams@intel.com>,
        Doug Ledford <dledford@redhat.com>,
        Sean Hefty <sean.hefty@intel.com>,
        Hal Rosenstock <hal.rosenstock@gmail.com>,
        jeffrey.t.kirsher@intel.com,
        "David S. Miller" <davem@davemloft.net>, stas.yakovlev@gmail.com,
        "James E.J. Bottomley" <jejb@linux.vnet.ibm.com>,
        "Martin K. Petersen" <martin.petersen@oracle.com>,
        Felipe Balbi <balbi@kernel.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        linux-usb@vger.kernel.org, linux-scsi@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Peter Senna Tschudin <peter.senna@collabora.co.uk>
To: Romain Perier <romain.perier@collabora.com>,
        Peter Senna Tschudin <peter.senna@collabora.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <7ebf56b6-4e22-05ba-2534-61cd03a2c87c@collabora.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2017-02-27 at 13:26 +0100, Romain Perier wrote:
> Hello,
> 
> 
> Le 27/02/2017 à 12:22, Peter Senna Tschudin a écrit :
> > On Sun, Feb 26, 2017 at 08:24:25PM +0100, Romain Perier wrote:
> > > pci_pool_*() functions should be replaced by the corresponding functions
> > > in the DMA pool API. This adds support to check for use of these pci
> > > functions and display a warning when it is the case.
> > > 
> > 
> > I guess Joe Perches did sent some comments for this one, did you address
> > them?
> 
> See the changelog of 00/20 (for v2). I have already integrated his
> comments :)

Not quite.  You need to add blank lines before and after
the new test you added.

I also wonder if you've in fact converted all of the
pci_pool struct and function uses why a new checkpatch
test is needed at all.

Also, it seems none of these patches have reached lkml.
Are you sending the patch series with MIME/html parts?  

> > Reviewed-by: Peter Senna Tschudin <peter.senna@collabora.com>
> > > Signed-off-by: Romain Perier <romain.perier@collabora.com>
> > > ---
> > >  scripts/checkpatch.pl | 9 ++++++++-
> > >  1 file changed, 8 insertions(+), 1 deletion(-)
> > > 
> > > diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
> > > index baa3c7b..f2c775c 100755
> > > --- a/scripts/checkpatch.pl
> > > +++ b/scripts/checkpatch.pl
> > > @@ -6064,7 +6064,14 @@ sub process {
> > >  			WARN("USE_DEVICE_INITCALL",
> > >  			     "please use device_initcall() or more appropriate function instead of __initcall() (see include/linux/init.h)\n" . $herecurr);
> > >  		}
> > > -
> > > +# check for old PCI api pci_pool_*(), use dma_pool_*() instead
> > > +		if ($line =~ /\bpci_pool(?:_(?:create|destroy|alloc|zalloc|free)|)\b/) {
> > > +			if (WARN("USE_DMA_POOL",
> > > +				 "please use the dma pool api or more appropriate function instead of the old pci pool api\n" . $herecurr) &&
> > > +			    $fix) {
> > > +				while ($fixed[$fixlinenr] =~ s/\bpci_pool(_(?:create|destroy|alloc|zalloc|free)|)\b/dma_pool$1/) {}
> > > +			}
> > > +		}
> > >  # check for various structs that are normally const (ops, kgdb, device_tree)
> > >  		if ($line !~ /\bconst\b/ &&
> > >  		    $line =~ /\bstruct\s+($const_structs)\b/) {
> > > -- 
> > > 2.9.3
