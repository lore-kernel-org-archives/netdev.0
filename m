From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH 25/37] drivers/infiniband: use .dev.of_node instead of .node in struct of_device
Date: Thu, 11 Mar 2010 11:57:53 -0800
Message-ID: <adavdd2d41q.fsf@roland-alpha.cisco.com>
References: <20100311174830.4824.19820.stgit@angua>
	<20100311180605.4824.3613.stgit@angua>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hoang-Nam Nguyen <hnguyen@de.ibm.com>,
	Christoph Raisch <raisch@de.ibm.com>, monstr@monstr.eu,
	gregkh@suse.de, benh@kernel.crashing.org,
	akpm@linux-foundation.org, davem@davemloft.net,
	sfr@canb.auug.org.au, jgarzik@pobox.com, ben-linux@fluff.org,
	dwmw2@infradead.org, jeremy.kerr@canonical.com,
	James.Bottomley@suse.de, broonie@opensource.wolfsonmicro.com,
	microblaze-uclinux@itee.uq.edu.au, linux-kernel@vger.kernel.org,
	linuxppc-dev@ozlabs.org, sparclinux@vger.kernel.org,
	linux-ide@vger.kernel.org, netdev@vger.kernel.org,
	linux-i2c@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	linux-scsi@vger.kernel.org, alsa-devel@alsa-project.org
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <sparclinux-owner@vger.kernel.org>
In-Reply-To: <20100311180605.4824.3613.stgit@angua> (Grant Likely's message of
	"Thu, 11 Mar 2010 11:06:06 -0700")
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Seems fine... adding EHCA guys just to make sure.

 > .node is being removed
 > 
 > Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
 > ---
 > 
 >  drivers/infiniband/hw/ehca/ehca_main.c |   11 ++++++-----
 >  1 files changed, 6 insertions(+), 5 deletions(-)
 > 
 > diff --git a/drivers/infiniband/hw/ehca/ehca_main.c b/drivers/infiniband/hw/ehca/ehca_main.c
 > index 129a6be..2639185 100644
 > --- a/drivers/infiniband/hw/ehca/ehca_main.c
 > +++ b/drivers/infiniband/hw/ehca/ehca_main.c
 > @@ -291,8 +291,9 @@ static int ehca_sense_attributes(struct ehca_shca *shca)
 >  	};
 >  
 >  	ehca_gen_dbg("Probing adapter %s...",
 > -		     shca->ofdev->node->full_name);
 > -	loc_code = of_get_property(shca->ofdev->node, "ibm,loc-code", NULL);
 > +		     shca->ofdev->dev.of_node->full_name);
 > +	loc_code = of_get_property(shca->ofdev->dev.of_node, "ibm,loc-code",
 > +				   NULL);
 >  	if (loc_code)
 >  		ehca_gen_dbg(" ... location lode=%s", loc_code);
 >  
 > @@ -720,16 +721,16 @@ static int __devinit ehca_probe(struct of_device *dev,
 >  	int ret, i, eq_size;
 >  	unsigned long flags;
 >  
 > -	handle = of_get_property(dev->node, "ibm,hca-handle", NULL);
 > +	handle = of_get_property(dev->dev.of_node, "ibm,hca-handle", NULL);
 >  	if (!handle) {
 >  		ehca_gen_err("Cannot get eHCA handle for adapter: %s.",
 > -			     dev->node->full_name);
 > +			     dev->dev.of_node->full_name);
 >  		return -ENODEV;
 >  	}
 >  
 >  	if (!(*handle)) {
 >  		ehca_gen_err("Wrong eHCA handle for adapter: %s.",
 > -			     dev->node->full_name);
 > +			     dev->dev.of_node->full_name);
 >  		return -ENODEV;
 >  	}
 >  
 > 
 > -- 
Roland Dreier  <rolandd@cisco.com>
For corporate legal information go to:
http://www.cisco.com/web/about/doing_business/legal/cri/index.html
