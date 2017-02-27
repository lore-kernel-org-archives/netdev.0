From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v3 20/20] checkpatch: warn for use of old PCI pool API
Date: Mon, 27 Feb 2017 03:53:24 -0800
Message-ID: <1488196404.25838.1.camel@perches.com>
References: <20170226192425.13098-1-romain.perier@collabora.com>
         <20170226192425.13098-21-romain.perier@collabora.com>
         <20170227112233.GK26544@collabora.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
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
To: Peter Senna Tschudin <peter.senna@collabora.com>,
        Romain Perier <romain.perier@collabora.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0136.hostedemail.com ([216.40.44.136]:44453 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751792AbdB0Lyg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Feb 2017 06:54:36 -0500
In-Reply-To: <20170227112233.GK26544@collabora.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-02-27 at 12:22 +0100, Peter Senna Tschudin wrote:
> On Sun, Feb 26, 2017 at 08:24:25PM +0100, Romain Perier wrote:
> > pci_pool_*() functions should be replaced by the corresponding functions
> > in the DMA pool API. This adds support to check for use of these pci
> > functions and display a warning when it is the case.
> > 
> 
> I guess Joe Perches did sent some comments for this one, did you address
> them?


> Reviewed-by: Peter Senna Tschudin <peter.senna@collabora.com>
> > Signed-off-by: Romain Perier <romain.perier@collabora.com>
> > ---
> >  scripts/checkpatch.pl | 9 ++++++++-
> >  1 file changed, 8 insertions(+), 1 deletion(-)
> > 
> > diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
> > index baa3c7b..f2c775c 100755
> > --- a/scripts/checkpatch.pl
> > +++ b/scripts/checkpatch.pl
> > @@ -6064,7 +6064,14 @@ sub process {
> >  			WARN("USE_DEVICE_INITCALL",
> >  			     "please use device_initcall() or more appropriate function instead of __initcall() (see include/linux/init.h)\n" . $herecurr);
> >  		}
> > -
> > +# check for old PCI api pci_pool_*(), use dma_pool_*() instead
> > +		if ($line =~ /\bpci_pool(?:_(?:create|destroy|alloc|zalloc|free)|)\b/) {
> > +			if (WARN("USE_DMA_POOL",
> > +				 "please use the dma pool api or more appropriate function instead of the old pci pool api\n" . $herecurr) &&
> > +			    $fix) {
> > +				while ($fixed[$fixlinenr] =~ s/\bpci_pool(_(?:create|destroy|alloc|zalloc|free)|)\b/dma_pool$1/) {}
> > +			}
> > +		}
> >  # check for various structs that are normally const (ops, kgdb, device_tree)
> >  		if ($line !~ /\bconst\b/ &&
> >  		    $line =~ /\bstruct\s+($const_structs)\b/) {
> > 

This is nearly identical to the suggestion that I
sent but this is slightly misformatted as it does
not have a leading nor a trailing blank line to
separate the test blocks.

Also, I think none of the patches have reached lkml.

Romain, are you using git-send-email to send these
patches?  Perhaps the patches you send also contain
html which are rejected by the mailing list.
