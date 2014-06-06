From: "Williams, Mitch A" <mitch.a.williams@intel.com>
Subject: RE: [net-next 04/13] i40evf: make messages less dire
Date: Fri, 6 Jun 2014 17:23:52 +0000
Message-ID: <AAEA33E297BCAC4B9BB20A7C2DF0AB8D656C8CB3@FMSMSX113.amr.corp.intel.com>
References: <1402045462-10304-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1402045462-10304-5-git-send-email-jeffrey.t.kirsher@intel.com>
 <1402057157.3038.8.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Joe Perches <joe@perches.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:38175 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752072AbaFFRXy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2014 13:23:54 -0400
In-Reply-To: <1402057157.3038.8.camel@joe-AO725>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Joe Perches [mailto:joe@perches.com]
> Sent: Friday, June 06, 2014 5:19 AM
> To: Kirsher, Jeffrey T
> Cc: davem@davemloft.net; Williams, Mitch A; netdev@vger.kernel.org;
> gospo@redhat.com; sassmann@redhat.com
> Subject: Re: [net-next 04/13] i40evf: make messages less dire
> 
> On Fri, 2014-06-06 at 02:04 -0700, Jeff Kirsher wrote:
> > Depending on the timing of what the PF driver is doing, it make take a
> > few tries before the VF driver is able to communicate with the PF driver
> > on init or reset recovery. In order to prevent confusion, make the most
> > common messages less scary by lowering them to a less terrifying log
> > level and indicate that the driver will retry.
> []
> > diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
> b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
> []
> > @@ -1963,7 +1963,7 @@ static void i40evf_init_task(struct work_struct
> *work)
> >  		}
> >  		err = i40evf_check_reset_complete(hw);
> >  		if (err) {
> > -			dev_err(&pdev->dev, "Device is still in reset (%d)\n",
> > +			dev_info(&pdev->dev, "Device is still in reset (%d),
> retrying\n",
> >  				err);
> >  			goto err;
> >  		}
> > @@ -1996,7 +1996,7 @@ static void i40evf_init_task(struct work_struct
> *work)
> >  		/* aq msg sent, awaiting reply */
> >  		err = i40evf_verify_api_ver(adapter);
> >  		if (err) {
> > -			dev_err(&pdev->dev, "Unable to verify API version (%d)\n",
> > +			dev_info(&pdev->dev, "Unable to verify API version (%d),
> retrying\n",
> >  				err);
> >  			goto err;
> >  		}
> 
> trivia:
> 
> It'd be nicer to reindent the multi-line statements.
> 
> CHECK: Alignment should match open parenthesis
> #73: FILE: drivers/net/ethernet/intel/i40evf/i40evf_main.c:1967:
> +			dev_info(&pdev->dev, "Device is still in reset (%d),
> retrying\n",
>  				err);
> 
> CHECK: Alignment should match open parenthesis
> #82: FILE: drivers/net/ethernet/intel/i40evf/i40evf_main.c:2000:
> +			dev_info(&pdev->dev, "Unable to verify API version (%d),
> retrying\n",
>  				err);
> 

Thanks, Joe. Thought I had those correct, but obviously I'm one character off here.

Now that checkpatch has been switch to pedantic mode, I think what I'll do is (once I get everything else working) run the entire driver through checkpatch and send out a single patch that fixes all of the formatting niggles.

-Mitch
